// SPDX-License-Identifier: MIT
// components: ["TreasureLinearChargingComponent", "TreasureTimerComponent", "ChargingComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectConfigComponent, ID as TreasureEffectConfigComponentID, TreasureEffectConfig} from "components/TreasureEffectConfigComponent.sol";
import {TreasureEffectGenerateConfigComponent, ID as TreasureEffectGenerateConfigComponentID, TreasureEffectGenerateConfig} from "components/TreasureEffectGenerateConfigComponent.sol";
import {TreasureEffectConfigRegisterComponent, ID as TreasureEffectConfigRegisterComponentID} from "components/TreasureEffectConfigRegisterComponent.sol";
import {TreasureEffectGlobalConfigComponent, ID as TreasureEffectGlobalConfigComponentID, TreasureEffectGlobalConfig} from "components/TreasureEffectGlobalConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

import {PlayerBelongingComponent, ID as PlayerBelongingComponentID} from "components/PlayerBelongingComponent.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID} from "components/TreasureBoundedComponent.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {TreasureLinearChargingComponent, ID as TreasureLinearChargingComponentID, TreasureLinearCharging} from "components/TreasureLinearChargingComponent.sol";
import {ChargingComponent, ID as ChargingComponentID, Charging} from "components/ChargingComponent.sol";
import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.ChargeLinearTreasure"));

struct ChargeTreasureInfo {
    uint256 treasureId;
    CoordVerifyParam position;
    uint32 direction;
    uint64 distance;
    uint32 area;
}

contract ChargeLinearTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        ChargeTreasureInfo memory chargeTreasureInfo = abi.decode(args, (ChargeTreasureInfo));
        return executeTyped(chargeTreasureInfo);
    }

    function executeTyped(
        ChargeTreasureInfo memory chargeTreasureInfo
    ) public returns (bytes memory) {
        uint256 entityId = addressToEntity(msg.sender);
        // require(!ChargingComponent(getAddressById(components, ChargingComponentID)).has(entityId), "Charging");
        require(checkCoordZK(chargeTreasureInfo.position, components), "Position invalid");

        //verify belonging
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        Treasurev2Component treasureComponent = Treasurev2Component(
            getAddressById(components, Treasurev2ComponentID)
        );
        require(playerBelonging.has(chargeTreasureInfo.treasureId) && playerBelonging.getValue(chargeTreasureInfo.treasureId) == entityId && treasureComponent.has(chargeTreasureInfo.treasureId), "not valid treasure");
        //verify TreasureComponent.use_mode == 1 && TreasureComponent.hitMode == 0
        Treasure memory treasure = treasureComponent.getValue(chargeTreasureInfo.treasureId);
        require(treasure.useMode == 1 && treasure.hitMode == 0, "not for this use mode");
        //verify TreasureTimerComponent.cooldown_timeout < block.timestamp
        TreasureTimerComponent treasureTimerComponent = TreasureTimerComponent(
            getAddressById(components, TreasureTimerComponentID)
        );
        TreasureTimer memory treasureTimer = treasureTimerComponent.getValue(chargeTreasureInfo.treasureId);
        require(treasureTimer.cooldownTimeout <= uint64(block.timestamp) && treasureTimer.chargingTimeout <= uint64(block.timestamp), "not cooldown yet");
        //get TreasureEffectComponent.
        TreasureEffectv2Component treasureEffectComponent = TreasureEffectv2Component(
            getAddressById(components, TreasureEffectv2ComponentID)
        );
        TreasureEffect memory treasureEffect = treasureEffectComponent.getValue(chargeTreasureInfo.treasureId);
        // set TreasureLinearCharging
        TreasureLinearChargingComponent(
            getAddressById(components, TreasureLinearChargingComponentID)
        ).set(chargeTreasureInfo.treasureId, TreasureLinearCharging({coordHash: chargeTreasureInfo.position.realHash,
            direction: chargeTreasureInfo.direction,
            distance: chargeTreasureInfo.distance,
            area: treasureEffect.area
        }));
        treasureTimerComponent.set(chargeTreasureInfo.treasureId, TreasureTimer({cooldownTimeout: uint64(block.timestamp)+treasure.cooldownTime,
            chargingTimeout: uint64(block.timestamp)+10
        }));
        ChargingComponent(getAddressById(components, ChargingComponentID)).set(entityId, Charging({chargingEntity: chargeTreasureInfo.treasureId, chargingTimeout: uint64(block.timestamp)}));//Edit ChargeTimeout
        // //use TreasureEffectSystem
        // CoordVerifyParam[] memory path;
        // CoordVerifyParam[] memory area;
        // TreasureEffectSystem(
        //     getAddressById(world.systems(), uint256(keccak256(abi.encode(TreasureEffectConfigComponent(
        //         getAddressById(components, TreasureEffectConfigComponentID)
        //     ).getValue(treasureEffect.effectType).effectID))))
        // ).executeTyped(TreasureEffectInfo({
        //         sourceID: ID,
        //         isComponent: false,
        //         entity: entityId,
        //         treasureID: treasureId,
        //         path: path,
        //         area: area,
        //         value: treasureEffect.value
        // }));
        // //calculate TreasureComponent.usage_times
        // if (treasure.usageTimes == 1) {
        //     playerBelonging.remove(entityId);
        //     treasureComponent.remove(entityId);
        //     treasureTimerComponent.remove(entityId);
        //     treasureEffectComponent.remove(entityId);
        // } else if (treasure.usageTimes > 1) {
        //     //TreasureComponent.usage_times
        //     treasure.usageTimes = treasure.usageTimes - 1;
        //     treasureComponent.set(treasureId, treasure);
        // }

        // MoveCooldown memory movable = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).getValue(entityId);
        // MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
        // require(
        //     movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
        //     "no action points"
        // );
        // uint64 remainPoints = movable.remainingMovePoints + (uint64(block.timestamp) - movable.lastMoveTime) / moveConfig.increaseCooldown - 1;
        // if (remainPoints > moveConfig.maxPoints) {
        //     remainPoints = moveConfig.maxPoints;
        // }
        // MoveCooldownComponent(
        //     getAddressById(components, MoveCooldownComponentID)
        // ).set(entityId, MoveCooldown(uint64(block.timestamp), remainPoints));
    }
}
