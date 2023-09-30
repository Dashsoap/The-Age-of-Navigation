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
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID, TreasureBounded} from "components/TreasureBoundedComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {ITreasureVerifier} from "verifiers/TreasureVerifierv2.sol";
import {ITreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.GuildBoundTreasure"));

struct Info {
    uint256 treasureId;
    uint256 guildCrestId;
}

contract GuildBoundTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    event Debug(string, uint256);

    function execute(bytes memory args) public returns (bytes memory) {
        Info memory info = abi.decode(args, (Info));
        return executeTyped(info);
    }

    function executeTyped(
        Info memory info
    ) public returns (bytes memory) {
        uint256 treasureId = info.treasureId;
        // uint256 entityId = addressToEntity(msg.sender);

        //verify belonging
        // PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
        //     getAddressById(components, PlayerBelongingComponentID)
        // );
        (uint256[] memory entityIds, uint256 guildId) = checkGuildCrest(treasureId, info.guildCrestId);
        Treasurev2Component treasureComponent = Treasurev2Component(
            getAddressById(components, Treasurev2ComponentID)
        );
        // require(playerBelonging.has(treasureId) && playerBelonging.getValue(treasureId) == entityId && treasureComponent.has(treasureId), "not valid treasure");
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
            boundPassiveTreasure(treasureId, entityIds, guildId);
        }
        treasureBoundedComponent.set(treasureId, TreasureBounded({boundTime: uint64(block.timestamp), timeout: uint64(block.timestamp) + treasure.cooldownTime}));
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

    function boundPassiveTreasure(uint256 treasureId, uint256[] memory entityIds, uint256 guildId) internal {
        // uint256 entityId = addressToEntity(msg.sender);

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
        for (uint256 index = 0; index < entityIds.length; index++) {
            ITreasureEffectSystem(
                getSystemAddress(treasureEffect.effectType)
            ).executeTyped(TreasureEffectInfo({
                    sourceID: ID,
                    isComponent: false,
                    entity: entityIds[index],
                    treasureID: treasureId,
                    path: path,
                    area: area,
                    areaAmount: 1,
                    value: treasureEffect.value
            }));
        }

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
            // treasureComponent.remove(treasureId);
            // treasureTimerComponent.remove(treasureId);
            // treasureEffectComponent.remove(treasureId);
        } else if (treasure.usageTimes > 1) {
            //TreasureComponent.usage_times
            treasure.usageTimes = treasure.usageTimes - 1;
            treasureComponent.set(treasureId, treasure);
            treasureTimerComponent.set(treasureId, TreasureTimer({cooldownTimeout: uint64(block.timestamp) + treasure.cooldownTime, chargingTimeout: uint64(block.timestamp)}));
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
