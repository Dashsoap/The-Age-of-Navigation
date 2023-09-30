// SPDX-License-Identifier: MIT
// components: ["GuildCrestComponent", "GuildCrestPendingComponent", "GuildCrestGuildComponent"]
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

uint256 constant ID = uint256(keccak256("system.RejectGuild"));

struct Info {
    uint256 guildCrestId;
}

contract RejectGuildSystem is System {
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
        GuildCrestPendingComponent guildCrestPending = GuildCrestPendingComponent(getAddressById(components, GuildCrestPendingComponentID));
        uint256 guildId = guildCrestPending.getValue(guildCrestId);
        // check entity has authority to operate
        checkAuthority(guildId);

        // check guild not reached limit
        GuildConfig memory guildConfig = GuildConfigComponent(
            getAddressById(components, GuildConfigComponentID)
        ).getValue();
        // checkGuild(guildId, guildConfig.basicCountLimit);

        guildCrestComponent.remove(guildCrestId);
        if (guildCrestPending.has(guildCrestId)) {
            guildCrestPending.remove(guildCrestId);
        }
        // GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID)).set(guildCrestId, guildId);
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
                require(guildCrest.level >= 2, "has no authority");
                found = true;
                break;
            }
            // require(guildCrestGuildComponent.getValue(guildCrestIds[index]) != guildId, "already in this guild");
            // require(guildCrestPendingComponent.getValue(guildCrestIds[index]) != guildId, "already pending");
        }
        require(found, "operator not in guild");
    }

    function checkGuild(uint256 guildId, uint32 countLimit) internal {
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        uint256[] memory guildCrestIds = guildCrestGuildComponent.getEntitiesWithValue(guildId);
        require(guildCrestIds.length < countLimit, "lack of positions");
    }
}
