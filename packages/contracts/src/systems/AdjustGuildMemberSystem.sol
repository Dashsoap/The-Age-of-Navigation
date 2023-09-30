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

uint256 constant ID = uint256(keccak256("system.AdjustGuildMember"));

struct AdjustMemberInfo {
    uint256 guildCrestId;
    uint32 level;
}

contract AdjustGuildMemberSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        AdjustMemberInfo memory adjustInfo = abi.decode(args, (AdjustMemberInfo));
        return executeTyped(adjustInfo);
    }

    function executeTyped(
        AdjustMemberInfo memory adjustInfo
    ) public returns (bytes memory) {
        uint256 guildCrestId = adjustInfo.guildCrestId;
        uint256 entityId = addressToEntity(msg.sender);

        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        // get guildId
        require(guildCrestComponent.has(guildCrestId), "crest invalid");
        GuildCrestGuildComponent guildCrestGuild = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        uint256 guildId = guildCrestGuild.getValue(guildCrestId);
        // check entity has authority to operate
        checkAuthority(guildId, guildCrestId, adjustInfo.level);
        GuildCrest memory targetGuildCrest = guildCrestComponent.getValue(guildCrestId);

        // execute
        guildCrestComponent.set(guildCrestId, GuildCrest({ level: adjustInfo.level, name: getName(adjustInfo.level), contribute: targetGuildCrest.contribute, allocate: targetGuildCrest.allocate, createTime: targetGuildCrest.createTime }));
    }

    function checkAuthority(uint256 guildId, uint256 guildCrestId, uint32 level) internal {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        GuildCrest memory guildCrestTarget = guildCrestComponent.getValue(guildCrestId);
        require(guildCrestTarget.level != level && level > 0, "invalid level");
        uint256[] memory guildCrestIds = guildCrestPlayerComponent.getEntitiesWithValue(entityId);
        bool found = false;
        for (uint256 index = 0; index < guildCrestIds.length; index++) {
            if (guildCrestGuildComponent.getValue(guildCrestIds[index]) == guildId) {
                GuildCrest memory guildCrest = guildCrestComponent.getValue(guildCrestIds[index]);
                require(guildCrest.level > guildCrestTarget.level && guildCrest.level > level, "has no authority");
                found = true;
                break;
            }
            // require(guildCrestGuildComponent.getValue(guildCrestIds[index]) != guildId, "already in this guild");
            // require(guildCrestPendingComponent.getValue(guildCrestIds[index]) != guildId, "already pending");
        }
        require(found, "operator not in guild");
    }

    function getName(uint32 level) internal returns (string memory) {
        GuildConfig memory guildConfig = GuildConfigComponent(
            getAddressById(components, GuildConfigComponentID)
        ).getValue();
        if (level == 1) {
            return guildConfig.initNameForLevel1;
        } else if (level == 2) {
            return guildConfig.initNameForLevel2;
        } else if (level == 3) {
            return guildConfig.initNameForLevel3;
        } else if (level == 4) {
            return guildConfig.initNameForLevel4;
        }
        return guildConfig.initNameForLevel0;
    }
}
