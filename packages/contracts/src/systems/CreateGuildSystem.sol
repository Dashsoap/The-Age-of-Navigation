// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "HiddenPositionComponent", "HPComponent", "HPLimitComponent", "MoveCooldownComponent", "GuildComponent", "GuildCrestComponent", "GuildCrestPlayerComponent", "GuildCrestGuildComponent", "GuildDisplayComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {GuildConfigComponent, ID as GuildConfigComponentID, GuildConfig} from "components/GuildConfigComponent.sol";
import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {HPComponent, ID as HPComponentID} from "components/HPComponent.sol";
import {HPLimitComponent, ID as HPLimitComponentID} from "components/HPLimitComponent.sol";
import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {GuildDisplayComponent, ID as GuildDisplayComponentID} from "components/GuildDisplayComponent.sol";
import {IInitVerifier} from "verifiers/InitVerifier.sol";

uint256 constant ID = uint256(keccak256("system.CreateGuild"));

struct CreateInfo {
    uint256 coordHash;
    uint256 width;
    uint256 height;
    uint256 seed;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    string flag;
    string name;
    string description;
    uint32 regime;
}

contract CreateGuildSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        CreateInfo memory createInfo = abi.decode(args, (CreateInfo));
        return executeTyped(createInfo);
    }

    function executeTyped(
        CreateInfo memory createInfo
    ) public returns (bytes memory) {
        ZKConfig memory zkConfig = ZKConfigComponent(
            getAddressById(components, ZKConfigComponentID)
        ).getValue();
        if (zkConfig.open) {
            uint256[4] memory input = [createInfo.coordHash, createInfo.seed, createInfo.width, createInfo.height];
            require(
                IInitVerifier(zkConfig.initVerifyAddress).verifyProof(
                    createInfo.a,
                    createInfo.b,
                    createInfo.c,
                    input
                ),
                "Failed guild coord proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);

        // check player not in a guild
        checkGuildCrest();

        // Check GoldAmount
        GuildConfig memory guildConfig = GuildConfigComponent(
            getAddressById(components, GuildConfigComponentID)
        ).getValue();
        checkGoldAmount(guildConfig.createCost);

        uint256 guildId = world.getUniqueEntityId();
        guildInit(guildId);
        GuildComponent(getAddressById(components, GuildComponentID)).set(guildId, Guild({leader: entityId,
            flag: createInfo.flag,
            name: createInfo.name,
            description: createInfo.description,
            createTime: uint64(block.timestamp),
            regime: createInfo.regime,
            taxRate: guildConfig.initTaxRate,
            resource: 0
        }));
        uint256 guildCrestId = world.getUniqueEntityId();
        GuildCrestComponent(getAddressById(components, GuildCrestComponentID)).set(guildCrestId, GuildCrest({ level: 4,
            name: guildConfig.initNameForLevel4,
            contribute: guildConfig.createCost,
            allocate: 0,
            createTime: uint64(block.timestamp)
        }));
        GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID)).set(guildCrestId, entityId);
        GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID)).set(guildCrestId, guildId);
        GuildDisplayComponent guildDisplayComponent = GuildDisplayComponent(getAddressById(components, GuildDisplayComponentID));
        if (!guildDisplayComponent.has(entityId)) {
            guildDisplayComponent.set(entityId, guildCrestId);
        }
        HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).set(guildId, createInfo.coordHash);
    }

    function guildInit(uint256 guildId) internal {
        GoldAmountComponent(getAddressById(components, GoldAmountComponentID)).set(guildId, 0);
        HPComponent(getAddressById(components, HPComponentID)).set(guildId, 2);
        HPLimitComponent(getAddressById(components, HPLimitComponentID)).set(guildId, 2);
        MoveConfig memory moveConfig = MoveConfigComponent(
            getAddressById(components, MoveConfigComponentID)
        ).getValue();
        MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).set(guildId, MoveCooldown(uint64(block.timestamp), moveConfig.initPoints));
    }

    function checkGuildCrest() internal {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.getEntitiesWithValue(entityId).length == 0, "leader cannot in a guild");
    }

    function checkGoldAmount(uint256 cost) internal {
        uint256 entityId = addressToEntity(msg.sender);
        GoldAmountComponent goldAmountComponent = GoldAmountComponent(getAddressById(components, GoldAmountComponentID));
        require(goldAmountComponent.getValue(entityId) >= cost, "lack of resources");
        goldAmountComponent.set(
            entityId,
            goldAmountComponent.getValue(entityId) - cost
        );
    }
}
