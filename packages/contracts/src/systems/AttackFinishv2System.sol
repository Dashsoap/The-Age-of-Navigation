// SPDX-License-Identifier: MIT
// components: ["ChargingComponent", "AttackChargeComponent", "TileAnimationComponent", "AttackTimerComponent", "HPComponent", "ShieldComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ResourceConfigComponent, ID as ResourceConfigComponentID, ResourceConfig} from "components/ResourceConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";

import {AttackChargeComponent, ID as AttackChargeComponentID, AttackCharge} from "components/AttackChargeComponent.sol";
import {AttackTimerComponent, ID as AttackTimerComponentID, AttackTimer} from "components/AttackTimerComponent.sol";
import {ChargingComponent, ID as ChargingComponentID, Charging} from "components/ChargingComponent.sol";
import {TileAnimationComponent, ID as TileAnimationComponentID, TileAnimation} from "components/TileAnimationComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
// import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
// import {WarshipComponent, ID as WarshipComponentID} from "components/WarshipComponent.sol";
// import {PlayerComponent, ID as PlayerComponentID} from "components/PlayerComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID} from "components/MoveCooldownComponent.sol";
// import {HPComponent, ID as HPComponentID} from "components/HPComponent.sol";
// import {IAttackPathVerifier} from "verifiers/AttackPathVerifier.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";
import { TargetType, AttackBaseSystem } from "expension/AttackBaseSystem.sol";

uint256 constant ID = uint256(keccak256("system.AttackFinishv2"));

struct AttackFinishInfo {
    CoordVerifyParam[] path;
    CoordVerifyParam[] area;
}

contract AttackFinishv2System is AttackBaseSystem {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        AttackFinishInfo memory attackInfo = abi.decode(args, (AttackFinishInfo));
        return executeTyped(attackInfo);
    }

    function executeTyped(
        AttackFinishInfo memory attackInfo
    ) public returns (bytes memory) {
        require(attackInfo.path.length <= 5, "over range");
        require(attackInfo.area.length == 1, "only one target position valid");
        checkPath(attackInfo.path);
        // ZKConfig memory zkConfig = ZKConfigComponent(
        //     getAddressById(components, ZKConfigComponentID)
        // ).getValue();
        // if (zkConfig.open) {
        //     require(
        //         IAttackPathVerifier(zkConfig.attackPathVerifyAddress).verifyProof(
        //             attackInfo.a,
        //             attackInfo.b,
        //             attackInfo.c,
        //             attackInfo.input
        //         ),
        //         "Failed attack proof check"
        //     );
        // }
        uint256 entityId = addressToEntity(msg.sender);
        // ChargingComponent chargingComponent = ChargingComponent(getAddressById(components, ChargingComponentID));
        // require(chargingComponent.has(entityId) && chargingComponent.getValue(entityId).chargingEntity == entityId && chargingComponent.getValue(entityId).chargingTimeout < block.timestamp, "not Charging");
        // require(attackInfo.coordHash == HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).getValue(entityId), "not standing on required tile");

        // Constrain position to map size, wrapping around if necessary
        // AttackTimerComponent attackTimer = AttackTimerComponent(
        //     getAddressById(components, AttackTimerComponentID)
        // );
        // require(attackTimer.has(entityId), "not charging");
        // require(attackTimer.getValue(entityId).chargingTimeout <= block.timestamp, "charging not finished");
        solveAttack(attackInfo, entityId);
        // chargingComponent.remove(entityId);
        // AttackChargeComponent(
        //     getAddressById(components, AttackChargeComponentID)
        // ).remove(entityId);
        // AttackTimer memory timer = attackTimer.getValue(entityId);
        // require((timer.cooldownTimeout == 0 || block.timestamp > timer.cooldownTimeout) && (timer.chargingTimeout == 0 || block.timestamp > timer.chargingTimeout), "already attacking");
        // attackTimer.set(entityId, AttackTimer({cooldownTimeout: }));
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

    function solveAttack(AttackFinishInfo memory attackInfo, uint256 entityId) internal {
        TileAnimationComponent tileAnimation = TileAnimationComponent(
            getAddressById(components, TileAnimationComponentID)
        );
        uint64 timeout = uint64(block.timestamp) + 10;
        for (uint256 index = 0; index < attackInfo.path.length; index++) {
            if (index != (attackInfo.path.length - 1)) {
                tileAnimation.set(attackInfo.path[index].fogHash, TileAnimation({animation: "attackThrough", timeout: timeout}));
            }
        }
        for (uint256 index1 = 0; index1 < attackInfo.area.length; index1++) {
            checkCoordZK(attackInfo.area[index1], components);
            // uint256[] memory entities = hiddenPositionComponent.getEntitiesWithValue(attackInfo.area[index1].fogHash);
            (uint256 target, TargetType targetType) = searchTarget(attackInfo.area[index1].fogHash, entityId);
            if (target > 0) {
                tileAnimation.set(attackInfo.area[index1].fogHash, TileAnimation({animation: "hit", timeout: timeout}));
            } else {
                tileAnimation.set(attackInfo.area[index1].fogHash, TileAnimation({animation: "attackThrough", timeout: timeout}));
            }
            uint256 remainDamage = dealDamage(target, 1, targetType);
        }
        // MapConfig memory mapConfig = MapConfigv2Component(
        //     getAddressById(components, MapConfigv2ComponentID)
        // ).getValue();
        // AttackChargeComponent attackCharge = AttackChargeComponent(
        //     getAddressById(components, AttackChargeComponentID)
        // );
        // HiddenPositionComponent position = HiddenPositionComponent(
        //     getAddressById(components, HiddenPositionComponentID)
        // );
        // HPComponent hp = HPComponent(
        //     getAddressById(components, HPComponentID)
        // );
        // TileAnimationComponent tileAnimation = TileAnimationComponent(
        //     getAddressById(components, TileAnimationComponentID)
        // );
        // uint64 timeout = uint64(block.timestamp) + 10;
        // require(attackCharge.has(entityId) && attackCharge.getValue(entityId).coord_hash == attackInfo.input[0], "attack not from begining");
        // for (uint i=0; i<10; i++) {
        //     if (attackInfo.input[30+i] <= mapConfig.gameRadiusX &&
        //             attackInfo.input[40+i] <= mapConfig.gameRadiusY) {
        //         if (i > 0 && attackInfo.input[i] > 0) {
        //             uint256[] memory entities = position.getEntitiesWithValue(attackInfo.input[i]);
        //             if (entities.length == 0) {
        //                 tileAnimation.set(attackInfo.input[i], TileAnimation({animation: "attackThrough", timeout: timeout}));
        //                 continue;
        //             }
        //             uint256 hitPlayer = entities[0];
        //             uint256 hitHP = hp.getValue(hitPlayer);
        //             if (hp.has(hitPlayer) && hitHP > 0) {
        //                 hp.set(hitPlayer, hitHP - 1);
        //                 if (hitHP - 1 == 0) {
        //                     position.set(hitPlayer, 0);
        //                     hp.remove(hitPlayer);
        //                     GoldAmountComponent(
        //                         getAddressById(components, GoldAmountComponentID)
        //                     ).remove(hitPlayer);
        //                     WarshipComponent(
        //                         getAddressById(components, WarshipComponentID)
        //                     ).remove(hitPlayer);
        //                     PlayerComponent(
        //                         getAddressById(components, PlayerComponentID)
        //                     ).remove(hitPlayer);
        //                     MoveCooldownComponent(
        //                         getAddressById(components, MoveCooldownComponentID)
        //                     ).remove(hitPlayer);
        //                     tileAnimation.set(attackInfo.input[i], TileAnimation({animation: "dead", timeout: timeout}));
        //                 } else {
        //                     tileAnimation.set(attackInfo.input[i], TileAnimation({animation: "hit", timeout: timeout}));
        //                 }
        //                 break;
        //             }
        //         }
        //     }
        // }
    }
}
