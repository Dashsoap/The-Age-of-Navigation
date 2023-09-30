// SPDX-License-Identifier: MIT
// components: ["GuildCrestComponent", "GuildCrestPlayerComponent", "GuildCrestPendingComponent"]
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
import {GuildCrestPendingComponent, ID as GuildCrestPendingComponentID} from "components/GuildCrestPendingComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";

uint256 constant ID = uint256(keccak256("system.JoinGuild"));

struct JoinInfo {
    uint256 guildId;
}

contract JoinGuildSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        JoinInfo memory info = abi.decode(args, (JoinInfo));
        return executeTyped(info);
    }

    function executeTyped(
        JoinInfo memory info
    ) public returns (bytes memory) {
        uint256 guildId = info.guildId;
        uint256 entityId = addressToEntity(msg.sender);

        // check player not in this guild
        checkGuildCrest(guildId);
        // check guild not reached limit
        GuildConfig memory guildConfig = GuildConfigComponent(
            getAddressById(components, GuildConfigComponentID)
        ).getValue();
        checkGuild(guildId, guildConfig.basicCountLimit);

        uint256 guildCrestId = world.getUniqueEntityId();
        GuildCrestComponent(getAddressById(components, GuildCrestComponentID)).set(guildCrestId, GuildCrest({ level: 0,
            name: guildConfig.initNameForLevel0,
            contribute: 0,
            allocate: 0,
            createTime: uint64(block.timestamp)
        }));
        GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID)).set(guildCrestId, entityId);
        GuildCrestPendingComponent(getAddressById(components, GuildCrestPendingComponentID)).set(guildCrestId, guildId);
    }

    function checkGuildCrest(uint256 guildId) internal {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        GuildCrestPendingComponent guildCrestPendingComponent = GuildCrestPendingComponent(getAddressById(components, GuildCrestPendingComponentID));
        uint256[] memory guildCrestIds = guildCrestPlayerComponent.getEntitiesWithValue(entityId);
        for (uint256 index = 0; index < guildCrestIds.length; index++) {
            require(guildCrestGuildComponent.getValue(guildCrestIds[index]) != guildId, "already in this guild");
            require(guildCrestPendingComponent.getValue(guildCrestIds[index]) != guildId, "already pending");
        }
    }

    function checkGuild(uint256 guildId, uint32 countLimit) internal {
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        uint256[] memory guildCrestIds = guildCrestGuildComponent.getEntitiesWithValue(guildId);
        require(guildCrestIds.length < countLimit, "lack of positions");
    }
}
