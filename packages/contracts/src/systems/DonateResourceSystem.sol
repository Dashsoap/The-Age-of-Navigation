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
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";

uint256 constant ID = uint256(keccak256("system.DonateResource"));

struct DonateResourceInfo {
    uint256 guildCrestId;
    uint32 resourceType;
    uint256 amount;
}

contract DonateResourceSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        DonateResourceInfo memory donateResourceInfo = abi.decode(args, (DonateResourceInfo));
        return executeTyped(donateResourceInfo);
    }

    function executeTyped(
        DonateResourceInfo memory donateResourceInfo
    ) public returns (bytes memory) {
        uint256 guildCrestId = donateResourceInfo.guildCrestId;
        uint256 entityId = addressToEntity(msg.sender);

        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        // get guildId
        require(guildCrestComponent.has(guildCrestId), "crest invalid");
        // donate to entity's crest
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.getValue(guildCrestId) == entityId, "not owner");
        GuildCrestGuildComponent guildCrestGuild = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        uint256 guildId = guildCrestGuild.getValue(guildCrestId);
        GuildCrest memory guildCrest = guildCrestComponent.getValue(guildCrestId);
        GuildComponent guildComponent = GuildComponent(getAddressById(components, GuildComponentID));
        Guild memory guild = guildComponent.getValue(guildId);

        uint256 resource = checkResource(donateResourceInfo.amount, donateResourceInfo.resourceType, guildId);
        // execute
        if (resource > 0) {
            guildCrest.contribute = guildCrest.contribute + resource;
            guildCrestComponent.set(guildCrestId, guildCrest);
            guild.resource = guild.resource + resource;
            guildComponent.set(guildId, guild);
        }
    }

    function checkResource(uint256 amount, uint32 resourceType, uint256 guildId) internal returns (uint256) {
        uint256 entityId = addressToEntity(msg.sender);
        if (resourceType == 0) {
            GoldAmountComponent goldAmountComponent = GoldAmountComponent(getAddressById(components, GoldAmountComponentID));
            require(goldAmountComponent.getValue(entityId) > amount, "lack of resource");
            goldAmountComponent.set(entityId, goldAmountComponent.getValue(entityId) - amount);
            goldAmountComponent.set(guildId, goldAmountComponent.getValue(guildId) + amount);
            return amount;
        }
        return 0;
    }
}
