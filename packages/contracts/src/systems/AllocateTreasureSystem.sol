// SPDX-License-Identifier: MIT
// components: ["GuildCrestComponent", "PlayerBelongingComponent", "GuildComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {GuildConfigComponent, ID as GuildConfigComponentID, GuildConfig} from "components/GuildConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {PlayerBelongingComponent, ID as PlayerBelongingComponentID} from "components/PlayerBelongingComponent.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID, TreasureBounded} from "components/TreasureBoundedComponent.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";

uint256 constant ID = uint256(keccak256("system.AllocateTreasure"));

struct AllocateTreasureInfo {
    uint256 guildCrestId;
    uint256 treasureId;
}

contract AllocateTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        AllocateTreasureInfo memory allocateTreasureInfo = abi.decode(args, (AllocateTreasureInfo));
        return executeTyped(allocateTreasureInfo);
    }

    function executeTyped(
        AllocateTreasureInfo memory allocateTreasureInfo
    ) public returns (bytes memory) {
        uint256 guildCrestId = allocateTreasureInfo.guildCrestId;
        uint256 entityId = addressToEntity(msg.sender);

        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        // get guildId
        require(guildCrestComponent.has(guildCrestId), "crest invalid");
        // allocate to entity's crest
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        uint256 targetId = guildCrestPlayerComponent.getValue(guildCrestId);
        GuildCrestGuildComponent guildCrestGuild = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        uint256 guildId = guildCrestGuild.getValue(guildCrestId);
        checkAuthority(guildId);
        GuildCrest memory guildCrest = guildCrestComponent.getValue(guildCrestId);
        GuildComponent guildComponent = GuildComponent(getAddressById(components, GuildComponentID));
        Guild memory guild = guildComponent.getValue(guildId);

        uint256 resource = checkTreasure(allocateTreasureInfo.treasureId, targetId, guildId, guild.resource);
        // execute
        if (resource > 0) {
            guildCrest.allocate = guildCrest.allocate + resource;
            guildCrestComponent.set(guildCrestId, guildCrest);
            guild.resource = guild.resource - resource;
            guildComponent.set(guildId, guild);
        }
    }

    function checkTreasure(uint256 treasureId, uint256 targetId, uint256 guildId, uint256 guildResource) internal returns (uint256) {
        PlayerBelongingComponent playerBelongingComponent = PlayerBelongingComponent(getAddressById(components, PlayerBelongingComponentID));
        require(playerBelongingComponent.has(treasureId) && playerBelongingComponent.getValue(treasureId) == guildId, "invalid treasure");
        TreasureBoundedComponent treasureBoundedComponent = TreasureBoundedComponent(getAddressById(components, TreasureBoundedComponentID));
        require((!treasureBoundedComponent.has(treasureId)) || (treasureBoundedComponent.getValue(treasureId).timeout < uint64(block.timestamp)), "treasure Bounded");
        uint256 resource = uint256(Treasurev2Component(getAddressById(components, Treasurev2ComponentID)).getValue(treasureId).energy);
        require(resource <= guildResource, "lack of resource points");
        playerBelongingComponent.set(treasureId, targetId);
        return resource;
    }

    function checkAuthority(uint256 guildId) internal {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        uint256[] memory guildCrestIds = guildCrestPlayerComponent.getEntitiesWithValue(entityId);
        bool found = false;
        for (uint256 index = 0; index < guildCrestIds.length; index++) {
            if (guildCrestGuildComponent.getValue(guildCrestIds[index]) == guildId) {
                GuildCrest memory guildCrest = guildCrestComponent.getValue(guildCrestIds[index]);
                require(guildCrest.level >= 3, "has no authority");
                found = true;
                break;
            }
            // require(guildCrestGuildComponent.getValue(guildCrestIds[index]) != guildId, "already in this guild");
            // require(guildCrestPendingComponent.getValue(guildCrestIds[index]) != guildId, "already pending");
        }
        require(found, "operator not in guild");
    }
}
