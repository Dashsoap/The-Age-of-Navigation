// SPDX-License-Identifier: MIT
// components: ["Treasurev2Component", "TreasureEffectv2Component", "TreasureTimerComponent", "PlayerBelongingComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";


import {BuffBelongingComponent, ID as BuffBelongingComponentID} from "components/BuffBelongingComponent.sol";
import {BuffComponent, ID as BuffComponentID, Buff} from "components/BuffComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.TreasureEffectDeathKeepResource"));
uint256 constant BuffID = uint256(keccak256("system.BuffEffectKeepResourceOnDeathExecute"));
uint256 constant ComponentID = uint256(keccak256("component.HPLimit"));

contract TreasureEffectDeathKeepResourceSystem is TreasureEffectSystem {
    constructor(
        IWorld _world,
        address _components
    ) TreasureEffectSystem(_world, _components) {}

    function effectLogic(
        TreasureEffectInfo memory effectInfo
    ) internal override returns (bytes memory) {
        uint256 entityId = effectInfo.entity;
        uint256 buffId = world.getUniqueEntityId();
        //set buff for entity
        BuffComponent(
            getAddressById(components, BuffComponentID)
        ).set(buffId, Buff({
            buffType: BuffID,
            buffLevel: 1,
            source: "treasure",
            sourceID: effectInfo.treasureID,
            targetID: ComponentID,
            isAdd: true,
            buffValue: effectInfo.value,
            buffTimeout: uint64(block.timestamp + 43200)
        }));
        BuffBelongingComponent(
            getAddressById(components, BuffBelongingComponentID)
        ).set(buffId, entityId);
    }
}
