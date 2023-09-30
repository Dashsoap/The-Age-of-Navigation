// SPDX-License-Identifier: MIT
// components: ["GuildCrestComponent"]
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

uint256 constant ID = uint256(keccak256("system.TransferGuildLeader"));

struct Info {
    uint256 guildCrestId;
}

contract TransferGuildLeaderSystem is System {
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
        uint256 guildCrestId = info.guildCrestId;
        uint256 entityId = addressToEntity(msg.sender);

        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        // get guildId
        require(guildCrestComponent.has(guildCrestId), "crest invalid");
        GuildCrestGuildComponent guildCrestGuild = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        uint256 guildId = guildCrestGuild.getValue(guildCrestId);
        // check entity has authority to operate
        (GuildCrest memory selfGuildCrest, uint256 selfGuildCrestId) = checkAuthority(guildId);
        GuildCrest memory targetGuildCrest = guildCrestComponent.getValue(guildCrestId);

        // execute
        guildCrestComponent.set(guildCrestId, GuildCrest({ level: selfGuildCrest.level, name: selfGuildCrest.name, contribute: targetGuildCrest.contribute, allocate: targetGuildCrest.allocate, createTime: targetGuildCrest.createTime }));
        guildCrestComponent.set(selfGuildCrestId, GuildCrest({ level: targetGuildCrest.level, name: targetGuildCrest.name, contribute: selfGuildCrest.contribute, allocate: selfGuildCrest.allocate, createTime: selfGuildCrest.createTime }));
    }

    function checkAuthority(uint256 guildId) internal returns (GuildCrest memory, uint256) {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        uint256[] memory guildCrestIds = guildCrestPlayerComponent.getEntitiesWithValue(entityId);
        for (uint256 index = 0; index < guildCrestIds.length; index++) {
            if (guildCrestGuildComponent.getValue(guildCrestIds[index]) == guildId) {
                GuildCrest memory guildCrest = guildCrestComponent.getValue(guildCrestIds[index]);
                require(guildCrest.level == 4, "not the leader");
                return (guildCrest, guildCrestIds[index]);
            }
            // require(guildCrestGuildComponent.getValue(guildCrestIds[index]) != guildId, "already in this guild");
            // require(guildCrestPendingComponent.getValue(guildCrestIds[index]) != guildId, "already pending");
        }
        bool found = false;
        require(found, "operator not in guild");
    }
}
