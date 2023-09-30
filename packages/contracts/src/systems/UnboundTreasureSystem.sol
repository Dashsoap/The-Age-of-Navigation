// SPDX-License-Identifier: MIT
// components: ["TreasureBoundedComponent", "PlayerBelongingComponent", "BuffBelongingComponent", "BuffComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {WorldQueryFragment} from "solecs/interfaces/IWorld.sol";
import {QueryType, IComponent} from "solecs/interfaces/Query.sol";
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
// import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID, TreasureBounded} from "components/TreasureBoundedComponent.sol";
import {BuffBelongingComponent, ID as BuffBelongingComponentID} from "components/BuffBelongingComponent.sol";
import {BuffComponent, ID as BuffComponentID, Buff} from "components/BuffComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {ITreasureVerifier} from "verifiers/TreasureVerifierv2.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.UnboundTreasure"));

contract UnboundTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

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
        TreasureBoundedComponent treasureBoundedComponent = TreasureBoundedComponent(
            getAddressById(components, TreasureBoundedComponentID)
        );
        Treasure memory treasure = Treasurev2Component(getAddressById(components, Treasurev2ComponentID)).getValue(treasureId);
        require(playerBelonging.has(treasureId) && playerBelonging.getValue(treasureId) == entityId, "not valid treasure");
        require(treasureBoundedComponent.has(treasureId), "not bounded yet");
        if (treasure.useMode == 0) {
            removeBuffs(treasureId);
        }
        treasureBoundedComponent.remove(treasureId);
    }

    function removeBuffs(uint256 treasureId) internal {
        uint256 entityId = addressToEntity(msg.sender);
        BuffBelongingComponent buffBelongingComponent = BuffBelongingComponent(
            getAddressById(components, BuffBelongingComponentID)
        );
        BuffComponent buffComponent = BuffComponent(
            getAddressById(components, BuffComponentID)
        );
        uint256[] memory buffIds = buffBelongingComponent.getEntitiesWithValue(entityId);
        for (uint256 index = 0; index < buffIds.length; index++) {
            Buff memory buff = buffComponent.getValue(buffIds[index]);
            if (keccak256(abi.encodePacked(buff.source)) == keccak256(abi.encodePacked("treasure")) && buff.sourceID == treasureId) {
                //remove buff
                if (buffBelongingComponent.has(buffIds[index])) {
                    buffBelongingComponent.remove(buffIds[index]);
                }
                buffComponent.remove(buffIds[index]);
            }
        }
    }
}
