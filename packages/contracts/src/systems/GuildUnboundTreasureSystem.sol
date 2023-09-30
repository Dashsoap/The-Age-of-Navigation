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
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
// import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID, TreasureBounded} from "components/TreasureBoundedComponent.sol";
import {BuffBelongingComponent, ID as BuffBelongingComponentID} from "components/BuffBelongingComponent.sol";
import {BuffComponent, ID as BuffComponentID, Buff} from "components/BuffComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {ITreasureVerifier} from "verifiers/TreasureVerifierv2.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.GuildUnboundTreasure"));

struct Info {
    uint256 treasureId;
    uint256 guildCrestId;
}

contract GuildUnboundTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        Info memory info = abi.decode(args, (Info));
        return executeTyped(info);
    }

    function executeTyped(
        Info memory info
    ) public returns (bytes memory) {
        uint256 treasureId = info.treasureId;
        // uint256 entityId = addressToEntity(msg.sender);

        // //verify belonging
        // PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
        //     getAddressById(components, PlayerBelongingComponentID)
        // );
        (uint256[] memory entityIds, uint256 guildId) = checkGuildCrest(treasureId, info.guildCrestId);
        TreasureBoundedComponent treasureBoundedComponent = TreasureBoundedComponent(
            getAddressById(components, TreasureBoundedComponentID)
        );
        Treasure memory treasure = Treasurev2Component(getAddressById(components, Treasurev2ComponentID)).getValue(treasureId);
        // require(playerBelonging.has(treasureId) && playerBelonging.getValue(treasureId) == entityId, "not valid treasure");
        require(treasureBoundedComponent.has(treasureId), "not bounded yet");
        if (treasure.useMode == 0) {
            for (uint256 index = 0; index < entityIds.length; index++) {
                removeBuffs(treasureId, entityIds[index]);
            }
        }
        treasureBoundedComponent.remove(treasureId);
    }

    function checkGuildCrest(uint256 treasureId, uint256 guildCrestId) internal returns (uint256[] memory, uint256) {
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.has(guildCrestId) && guildCrestPlayerComponent.getValue(guildCrestId) == entityId, "not owner of guild crest");
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        require(guildCrestComponent.has(guildCrestId) && guildCrestComponent.getValue(guildCrestId).level == 4, "not leader of guild");
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        require(guildCrestGuildComponent.has(guildCrestId), "no guild bounded");
        uint256 guildId = guildCrestGuildComponent.getValue(guildCrestId);
        Treasurev2Component treasureComponent = Treasurev2Component(getAddressById(components, Treasurev2ComponentID));
        require(playerBelonging.has(treasureId) && playerBelonging.getValue(treasureId) == guildId && treasureComponent.has(treasureId), "not valid treasure");
        uint256[] memory crestIds = guildCrestGuildComponent.getEntitiesWithValue(guildId);
        uint256[] memory entityIds = new uint256[](crestIds.length);
        for (uint256 index = 0; index < crestIds.length; index++) {
            entityIds[index] = guildCrestPlayerComponent.getValue(crestIds[index]);
        }
        return (entityIds, guildId);
    }

    function removeBuffs(uint256 treasureId, uint256 entityId) internal {
        // uint256 entityId = addressToEntity(msg.sender);
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
