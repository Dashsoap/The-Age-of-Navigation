// SPDX-License-Identifier: MIT
// components: ["TreasureAirdropChargingComponent", "TreasureTimerComponent", "ChargingComponent", "Treasurev2Component", "PlayerBelongingComponent", "TreasureEffectv2Component"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectConfigComponent, ID as TreasureEffectConfigComponentID, TreasureEffectConfig} from "components/TreasureEffectConfigComponent.sol";
import {TreasureEffectGenerateConfigComponent, ID as TreasureEffectGenerateConfigComponentID, TreasureEffectGenerateConfig} from "components/TreasureEffectGenerateConfigComponent.sol";
import {TreasureEffectConfigRegisterComponent, ID as TreasureEffectConfigRegisterComponentID} from "components/TreasureEffectConfigRegisterComponent.sol";
import {TreasureEffectGlobalConfigComponent, ID as TreasureEffectGlobalConfigComponentID, TreasureEffectGlobalConfig} from "components/TreasureEffectGlobalConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {GuildConfigComponent, ID as GuildConfigComponentID, GuildConfig} from "components/GuildConfigComponent.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

import {PlayerBelongingComponent, ID as PlayerBelongingComponentID} from "components/PlayerBelongingComponent.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import {TreasureBoundedComponent, ID as TreasureBoundedComponentID} from "components/TreasureBoundedComponent.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {TreasureAirdropChargingComponent, ID as TreasureAirdropChargingComponentID, TreasureAirdropCharging} from "components/TreasureAirdropChargingComponent.sol";
import {ChargingComponent, ID as ChargingComponentID, Charging} from "components/ChargingComponent.sol";
import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.GuildReleaseAirdropTreasure"));

struct ReleaseTreasureInfo {
    uint256 treasureId;
    CoordVerifyParam[] path;
    CoordVerifyParam[] area;
    uint256 guildCrestId;
}

contract GuildReleaseAirdropTreasureSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        ReleaseTreasureInfo memory releaseTreasureInfo = abi.decode(args, (ReleaseTreasureInfo));
        return executeTyped(releaseTreasureInfo);
    }

    function executeTyped(
        ReleaseTreasureInfo memory releaseTreasureInfo
    ) public returns (bytes memory) {
        // uint256 entityId = addressToEntity(msg.sender);
        uint256 entityId = checkGuildCrest(releaseTreasureInfo.treasureId, releaseTreasureInfo.guildCrestId);
        //verify belonging & charging finished
        //TODO: verify path.length == 0 and in range & area in area
        // ChargingComponent chargingComponent = ChargingComponent(getAddressById(components, ChargingComponentID));
        // require(chargingComponent.has(entityId) && chargingComponent.getValue(entityId).chargingEntity == releaseTreasureInfo.treasureId && chargingComponent.getValue(entityId).chargingTimeout < block.timestamp, "not Charging");
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        Treasurev2Component treasureComponent = Treasurev2Component(
            getAddressById(components, Treasurev2ComponentID)
        );
        require(playerBelonging.has(releaseTreasureInfo.treasureId) && playerBelonging.getValue(releaseTreasureInfo.treasureId) == entityId && treasureComponent.has(releaseTreasureInfo.treasureId), "not valid treasure");
        //verify TreasureComponent.use_mode == 1 && TreasureComponent.hitMode == 0
        Treasure memory treasure = treasureComponent.getValue(releaseTreasureInfo.treasureId);
        require(treasure.useMode == 1 && treasure.hitMode == 1, "not for this use mode");
        //get TreasureEffectComponent.
        TreasureEffectv2Component treasureEffectComponent = TreasureEffectv2Component(
            getAddressById(components, TreasureEffectv2ComponentID)
        );
        TreasureEffect memory treasureEffect = treasureEffectComponent.getValue(releaseTreasureInfo.treasureId);
        // remove TreasureAirdropCharging
        // TreasureAirdropChargingComponent(
        //     getAddressById(components, TreasureAirdropChargingComponentID)
        // ).remove(releaseTreasureInfo.treasureId);
        // chargingComponent.remove(entityId);
        GuildConfig memory guildConfig = GuildConfigComponent(
            getAddressById(components, GuildConfigComponentID)
        ).getValue();
        //use TreasureEffectSystem
        TreasureEffectSystem(
            getAddressById(world.systems(), TreasureEffectConfigComponent(
                getAddressById(components, TreasureEffectConfigComponentID)
            ).getValue(treasureEffect.effectType).effectID)
        ).executeTyped(TreasureEffectInfo({
                sourceID: ID,
                isComponent: false,
                entity: entityId,
                treasureID: releaseTreasureInfo.treasureId,
                path: releaseTreasureInfo.path,
                area: releaseTreasureInfo.area,
                areaAmount: treasureEffect.area,
                value: treasureEffect.value * guildConfig.basicValueFactor / 1000
        }));
        //calculate TreasureComponent.usage_times
        if (treasure.usageTimes == 1) {
            if (playerBelonging.has(releaseTreasureInfo.treasureId)) {
                playerBelonging.remove(releaseTreasureInfo.treasureId);
            }
            if (treasureComponent.has(releaseTreasureInfo.treasureId)) {
                treasureComponent.remove(releaseTreasureInfo.treasureId);
            }
            // TreasureTimerComponent(
            //     getAddressById(components, TreasureTimerComponentID)
            // ).remove(entityId);
            if (treasureEffectComponent.has(releaseTreasureInfo.treasureId)) {
                treasureEffectComponent.remove(releaseTreasureInfo.treasureId);
            }
        } else if (treasure.usageTimes > 1) {
            //TreasureComponent.usage_times
            treasure.usageTimes = treasure.usageTimes - 1;
            treasureComponent.set(releaseTreasureInfo.treasureId, treasure);
            TreasureTimerComponent(
                getAddressById(components, TreasureTimerComponentID)
            ).set(releaseTreasureInfo.treasureId, TreasureTimer({cooldownTimeout: uint64(block.timestamp)+treasure.cooldownTime, chargingTimeout: 0}));
        }

        // MoveCooldown memory movable = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).getValue(entityId);
        // MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
        // require(
        //     movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
        //     "no action points"
        // );
        // uint64 remainPoints = movable.remainingMovePoints + (uint64(block.timestamp) - movable.lastMoveTime) / moveConfig.increaseCooldown - 1;
        // if (remainPoints > moveConfig.maxPoints) {
        //     remainPoints = moveConfig.maxPoints;
        // }
        // MoveCooldownComponent(
        //     getAddressById(components, MoveCooldownComponentID)
        // ).set(entityId, MoveCooldown(uint64(block.timestamp), remainPoints));
    }

    function checkGuildCrest(uint256 treasureId, uint256 guildCrestId) internal returns (uint256) {
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.has(guildCrestId) && guildCrestPlayerComponent.getValue(guildCrestId) == entityId, "not owner of guild crest");
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        require(guildCrestComponent.has(guildCrestId) && guildCrestComponent.getValue(guildCrestId).level == 4, "not leader of guild");
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        require(guildCrestGuildComponent.has(guildCrestId), "no guild bounded");
        uint256 guildId = guildCrestGuildComponent.getValue(guildCrestId);
        Treasurev2Component treasureComponent = Treasurev2Component(getAddressById(components, Treasurev2ComponentID));
        require(playerBelonging.has(treasureId) && playerBelonging.getValue(treasureId) == guildId && treasureComponent.has(treasureId), "not valid treasure");
        return guildId;
    }
}
