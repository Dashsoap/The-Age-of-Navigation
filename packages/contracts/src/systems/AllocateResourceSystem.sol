// SPDX-License-Identifier: MIT
// components: ["GuildCrestComponent", "GoldAmountComponent", "GuildComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {GuildConfigComponent, ID as GuildConfigComponentID, GuildConfig} from "components/GuildConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {TreasureComponent, ID as TreasureComponentID, Treasure} from "components/TreasureComponent.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";

uint256 constant ID = uint256(keccak256("system.AllocateResource"));

struct AllocateResourceInfo {
    uint256 guildCrestId;
    uint32 resourceType;
    uint256 amount;
}

contract AllocateResourceSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        AllocateResourceInfo memory allocateResourceInfo = abi.decode(args, (AllocateResourceInfo));
        return executeTyped(allocateResourceInfo);
    }

    function executeTyped(
        AllocateResourceInfo memory allocateResourceInfo
    ) public returns (bytes memory) {
        uint256 guildCrestId = allocateResourceInfo.guildCrestId;
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

        uint256 resource = checkResource(allocateResourceInfo.amount, allocateResourceInfo.resourceType, targetId, guildId, guild.resource);
        // execute
        if (resource > 0) {
            guildCrest.allocate = guildCrest.allocate + resource;
            guildCrestComponent.set(guildCrestId, guildCrest);
            guild.resource = guild.resource - resource;
            guildComponent.set(guildId, guild);
        }
    }

    function checkResource(uint256 amount, uint32 resourceType, uint256 targetId, uint256 guildId, uint256 guildResource) internal returns (uint256) {
        if (resourceType == 0) {
            GoldAmountComponent goldAmountComponent = GoldAmountComponent(getAddressById(components, GoldAmountComponentID));
            uint256 resource = amount;
            require(resource <= guildResource, "lack of resource points");
            require(goldAmountComponent.getValue(guildId) >= amount, "lack of resource");
            goldAmountComponent.set(guildId, goldAmountComponent.getValue(guildId) - amount);
            goldAmountComponent.set(targetId, goldAmountComponent.getValue(targetId) + amount);
            return resource;
        }
        return 0;
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
