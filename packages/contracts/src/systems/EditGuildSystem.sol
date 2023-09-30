// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "GuildComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {GuildConfigComponent, ID as GuildConfigComponentID, GuildConfig} from "components/GuildConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

// import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
// import {HPComponent, ID as HPComponentID} from "components/HPComponent.sol";
// import {HPLimitComponent, ID as HPLimitComponentID} from "components/HPLimitComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
// import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";
// import {IInitVerifier} from "verifiers/InitVerifier.sol";

uint256 constant ID = uint256(keccak256("system.EditGuild"));

struct EditInfo {
    uint256 guildCrestId;
    string flag;
    string name;
    string description;
    uint32 regime;
    uint32 taxRate;
}

contract EditGuildSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        EditInfo memory editInfo = abi.decode(args, (EditInfo));
        return executeTyped(editInfo);
    }

    function executeTyped(
        EditInfo memory editInfo
    ) public returns (bytes memory) {
        // check player is leader of guild
        uint256 guildId = checkGuildCrest(editInfo.guildCrestId);

        // change info
        GuildComponent guildComponent = GuildComponent(getAddressById(components, GuildComponentID));
        Guild memory guild = guildComponent.getValue(guildId);
        guild.flag = editInfo.flag;
        guild.name = editInfo.name;
        guild.description = editInfo.description;
        guild.regime = editInfo.regime;
        guild.taxRate = editInfo.taxRate;
        guildComponent.set(guildId, guild);
    }

    function checkGuildCrest(uint256 guildCrestId) internal returns (uint256) {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.has(guildCrestId) && guildCrestPlayerComponent.getValue(guildCrestId) == entityId, "not owner of guild crest");
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        require(guildCrestComponent.has(guildCrestId) && guildCrestComponent.getValue(guildCrestId).level == 4, "not leader of guild");
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        require(guildCrestGuildComponent.has(guildCrestId), "no guild bounded");
        return guildCrestGuildComponent.getValue(guildCrestId);
    }
}
