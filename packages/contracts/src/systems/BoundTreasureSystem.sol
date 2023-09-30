// SPDX-License-Identifier: MIT
// components: ["Treasurev2Component", "TreasureBoundedComponent", "TreasureEffectv2Component", "TreasureTimerComponent", "PlayerBelongingComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld, IUint256Component} from "solecs/System.sol";
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
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID, TreasureBounded} from "components/TreasureBoundedComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {ITreasureVerifier} from "verifiers/TreasureVerifierv2.sol";
import {ITreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.BoundTreasure"));

contract BoundTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    event Debug(string, uint256);

    function execute(bytes memory args) public returns (bytes memory) {
        uint256 treasureId = abi.decode(args, (uint256));
        return executeTyped(treasureId);
    }

    function executeTyped(
        uint256 treasureId
    ) public returns (bytes memory) {
        uint256 entityId = addressToEntity(msg.sender);

        //verify belonging
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        Treasurev2Component treasureComponent = Treasurev2Component(
            getAddressById(components, Treasurev2ComponentID)
        );
        require(playerBelonging.has(treasureId) && playerBelonging.getValue(treasureId) == entityId && treasureComponent.has(treasureId), "not valid treasure");
        Treasure memory treasure = treasureComponent.getValue(treasureId);
        TreasureBoundedComponent treasureBoundedComponent = TreasureBoundedComponent(
            getAddressById(components, TreasureBoundedComponentID)
        );
        require((!treasureBoundedComponent.has(treasureId)) || (treasureBoundedComponent.getValue(treasureId).timeout < uint64(block.timestamp)), "already Bounded");
        if (treasure.useMode == 0) {
            TreasureTimerComponent treasureTimerComponent = TreasureTimerComponent(
                getAddressById(components, TreasureTimerComponentID)
            );
            require(treasureTimerComponent.getValue(treasureId).cooldownTimeout < uint64(block.timestamp), "not cooldown yet");
            boundPassiveTreasure(treasureId);
        }
        treasureBoundedComponent.set(treasureId, TreasureBounded({boundTime: uint64(block.timestamp), timeout: uint64(block.timestamp) + treasure.cooldownTime}));
    }

    function boundPassiveTreasure(uint256 treasureId) internal {
        uint256 entityId = addressToEntity(msg.sender);

        //verify belonging
        Treasurev2Component treasureComponent = Treasurev2Component(
            getAddressById(components, Treasurev2ComponentID)
        );
        //verify TreasureComponent.use_mode == 0
        Treasure memory treasure = treasureComponent.getValue(treasureId);
        //verify TreasureTimerComponent.cooldown_timeout < block.timestamp
        TreasureTimerComponent treasureTimerComponent = TreasureTimerComponent(
            getAddressById(components, TreasureTimerComponentID)
        );
        //get TreasureEffectComponent.
        TreasureEffectv2Component treasureEffectComponent = TreasureEffectv2Component(
            getAddressById(components, TreasureEffectv2ComponentID)
        );
        TreasureEffect memory treasureEffect = treasureEffectComponent.getValue(treasureId);
        //use TreasureEffectSystem
        CoordVerifyParam[] memory path;
        CoordVerifyParam[] memory area;
        ITreasureEffectSystem(
            getSystemAddress(treasureEffect.effectType)
        ).executeTyped(TreasureEffectInfo({
                sourceID: ID,
                isComponent: false,
                entity: entityId,
                treasureID: treasureId,
                path: path,
                area: area,
                areaAmount: 1,
                value: treasureEffect.value
        }));

        //calculate TreasureComponent.usage_times
        if (treasure.usageTimes == 1) {
            PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
                getAddressById(components, PlayerBelongingComponentID)
            );
            if (playerBelonging.has(treasureId)) {
                playerBelonging.remove(treasureId);
            }
            if (treasureComponent.has(treasureId)) {
                treasureComponent.remove(treasureId);
            }
            if (treasureTimerComponent.has(treasureId)) {
                treasureTimerComponent.remove(treasureId);
            }
            if (treasureEffectComponent.has(treasureId)) {
                treasureEffectComponent.remove(treasureId);
            }
        } else if (treasure.usageTimes > 1) {
            //TreasureComponent.usage_times
            treasure.usageTimes = treasure.usageTimes - 1;
            treasureComponent.set(treasureId, treasure);
            treasureTimerComponent.set(treasureId, TreasureTimer({cooldownTimeout: uint64(block.timestamp) + treasure.cooldownTime, chargingTimeout: uint64(block.timestamp)}));//Edit ChargeTimeout
        }
    }

    function getSystemAddress(uint256 effectType) internal returns (address) {
        TreasureEffectConfig memory config = TreasureEffectConfigComponent(
            getAddressById(components, TreasureEffectConfigComponentID)
        ).getValue(effectType);
        uint256 systemID = config.effectID;
        return getAddressById(world.systems(), systemID);
    }
}
