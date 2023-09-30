// SPDX-License-Identifier: MIT
// components: ["ShieldComponent", "TileAnimationComponent", "HPComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";

import {TileAnimationComponent, ID as TileAnimationComponentID, TileAnimation} from "components/TileAnimationComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";
import { TargetType, AttackBaseSystem } from "expension/AttackBaseSystem.sol";

uint256 constant ID = uint256(keccak256("system.TreasureEffectLinearDamage"));
// uint256 constant BuffID = uint256(keccak256("system.BuffEffectAddHPCalculateSystem"));

contract TreasureEffectLinearDamageSystem is TreasureEffectSystem, AttackBaseSystem {
    event Debug(string prex, uint256 value);

    constructor(
        IWorld _world,
        address _components
    ) TreasureEffectSystem(_world, _components) {}

    function effectLogic(
        TreasureEffectInfo memory effectInfo
    ) internal override returns (bytes memory) {
        uint256 entityId = effectInfo.entity;
        checkPath(effectInfo.path);
        TileAnimationComponent tileAnimation = TileAnimationComponent(
            getAddressById(components, TileAnimationComponentID)
        );
        uint64 timeout = uint64(block.timestamp) + 10;
        for (uint256 index = 0; index < effectInfo.path.length; index++) {
            if (index != (effectInfo.path.length - 1)) {
                tileAnimation.set(effectInfo.path[index].fogHash, TileAnimation({animation: "attackThrough", timeout: timeout}));
            }
        }
        // emit Debug("path:", effectInfo.path.length);
        // emit Debug("area:", effectInfo.area.length);
        for (uint256 index1 = 0; index1 < effectInfo.area.length; index1++) {
            checkCoordZK(effectInfo.area[index1], components);
            (uint256 target, TargetType targetType) = searchTarget(effectInfo.area[index1].fogHash, entityId);
            // emit Debug("attacking:", effectInfo.area[index1].fogHash);
            // emit Debug("attack target:", target);
            // emit Debug("attack target type:", uint256(targetType));
            // emit Debug("damage:", effectInfo.value);
            if (target > 0) {
                tileAnimation.set(effectInfo.area[index1].fogHash, TileAnimation({animation: "hit", timeout: timeout}));
            } else {
                tileAnimation.set(effectInfo.area[index1].fogHash, TileAnimation({animation: "attackThrough", timeout: timeout}));
            }
            uint256 remainDamage = dealDamage(target, effectInfo.value, targetType);
            // emit Debug("remain damage:", remainDamage);
        }
    }

    function checkPath(CoordVerifyParam[] memory path) internal {
        HiddenPositionComponent hiddenPositionComponent = HiddenPositionComponent(
            getAddressById(components, HiddenPositionComponentID)
        );
        for (uint256 index = 0; index < path.length; index++) {
            if (index != (path.length - 1)) {
                checkCoordZK(path[index], components);
                uint256[] memory entities = hiddenPositionComponent.getEntitiesWithValue(path[index].fogHash);
                require(entities.length == 0, "has Entity in path");
            }
        }
    }
}
