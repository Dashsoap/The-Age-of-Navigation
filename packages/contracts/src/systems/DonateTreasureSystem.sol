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
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID, TreasureBounded} from "components/TreasureBoundedComponent.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";

uint256 constant ID = uint256(keccak256("system.DonateTreasure"));

struct DonateTreasureInfo {
    uint256 guildCrestId;
    uint256 treasureId;
}

contract DonateTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        DonateTreasureInfo memory donateTreasureInfo = abi.decode(args, (DonateTreasureInfo));
        return executeTyped(donateTreasureInfo);
    }

    function executeTyped(
        DonateTreasureInfo memory donateTreasureInfo
    ) public returns (bytes memory) {
        uint256 guildCrestId = donateTreasureInfo.guildCrestId;
        uint256 entityId = addressToEntity(msg.sender);

        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        // get guildId
        require(guildCrestComponent.has(guildCrestId), "crest invalid");
        // donate to entity's crest
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.has(guildCrestId) && guildCrestPlayerComponent.getValue(guildCrestId) == entityId, "not owner");
        GuildCrestGuildComponent guildCrestGuild = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        require(guildCrestGuild.has(guildCrestId), "no GuildGrestId in guildcrestGuild");
        uint256 guildId = guildCrestGuild.getValue(guildCrestId);
        GuildCrest memory guildCrest = guildCrestComponent.getValue(guildCrestId);
        GuildComponent guildComponent = GuildComponent(getAddressById(components, GuildComponentID));
        require(guildComponent.has(guildId), "Guild has no GuildId");
        Guild memory guild = guildComponent.getValue(guildId);

        uint256 resource = checkTreasure(donateTreasureInfo.treasureId, guildId);
        // execute
        if (resource > 0) {
            guildCrest.contribute = guildCrest.contribute + resource;
            guildCrestComponent.set(guildCrestId, guildCrest);
            guild.resource = guild.resource + resource;
            guildComponent.set(guildId, guild);
        }
    }

    function checkTreasure(uint256 treasureId, uint256 guildId) internal returns (uint256) {
        uint256 entityId = addressToEntity(msg.sender);
        PlayerBelongingComponent playerBelongingComponent = PlayerBelongingComponent(getAddressById(components, PlayerBelongingComponentID));
        require(playerBelongingComponent.has(treasureId) && playerBelongingComponent.getValue(treasureId) == entityId, "invalid treasure");
        TreasureBoundedComponent treasureBoundedComponent = TreasureBoundedComponent(getAddressById(components, TreasureBoundedComponentID));
        require((!treasureBoundedComponent.has(treasureId)) || (treasureBoundedComponent.getValue(treasureId).timeout < uint64(block.timestamp)), "treasure Bounded");
        playerBelongingComponent.set(treasureId, guildId);
        return uint256(Treasurev2Component(getAddressById(components, Treasurev2ComponentID)).getValue(treasureId).energy);
    }
}
