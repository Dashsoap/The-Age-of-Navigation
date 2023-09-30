// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {TreasureEffectConfigComponent, ID as TreasureEffectConfigComponentID, TreasureEffectConfig} from "components/TreasureEffectConfigComponent.sol";
import {TreasureBuildConfigComponent, ID as TreasureBuildConfigComponentID} from "components/TreasureBuildConfigComponent.sol";
import {TreasureEffectGenerateConfigComponent, ID as TreasureEffectGenerateConfigComponentID, TreasureEffectGenerateConfig} from "components/TreasureEffectGenerateConfigComponent.sol";
import {TreasureEffectConfigRegisterComponent, ID as TreasureEffectConfigRegisterComponentID} from "components/TreasureEffectConfigRegisterComponent.sol";
import {TreasureEffectGlobalConfigComponent, ID as TreasureEffectGlobalConfigComponentID, TreasureEffectGlobalConfig} from "components/TreasureEffectGlobalConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

struct InnerTreasureEffectConfig {
    uint256 effectID;
    string effectName;
    string effectAsset;
    uint32 effectGroup;
    uint64 effectRarely;
    uint64 energyPerArea;
    uint64 energyPerValue;
    uint8 useMode;
    uint8 hitMode;
    uint64 basicCooldownTime;
    uint64 energyPerRange;
    uint32 basicUsageTimes;
    uint64 minArea;
    uint64 maxArea;
    uint64 minValue;
    uint64 maxValue;
}

library TreasureConfigv2Initializer {
    function init(IWorld world) internal {
        setTreasureEffectGlobalConfigs(world);
        TreasureBuildConfigComponent(
            world.getComponent(TreasureBuildConfigComponentID)
        ).set(1);
        TreasureEffectConfigComponent treasureEffectConfig = TreasureEffectConfigComponent(
            world.getComponent(TreasureEffectConfigComponentID)
        );
        TreasureEffectGenerateConfigComponent treasureEffectGenerateConfig = TreasureEffectGenerateConfigComponent(
            world.getComponent(TreasureEffectGenerateConfigComponentID)
        );
        TreasureEffectConfigRegisterComponent treasureEffectConfigRegister = TreasureEffectConfigRegisterComponent(
            world.getComponent(TreasureEffectConfigRegisterComponentID)
        );

        InnerTreasureEffectConfig[5] memory treasureEffectConfigs = [
            InnerTreasureEffectConfig({
                effectID: uint256(keccak256("system.TreasureEffectAirdropDefense")),
                effectName: "Shield Generator",
                effectAsset: "shield_generator",
                effectGroup: 1,
                effectRarely: 60,
                energyPerArea: 20,
                energyPerValue: 40,
                useMode: 1,
                hitMode: 1,
                basicCooldownTime: 10,//10s
                energyPerRange: 10,
                basicUsageTimes: 5,
                minArea: 1,
                maxArea: 3,
                minValue: 1,
                maxValue: 1
            }),
            InnerTreasureEffectConfig({
                effectID: uint256(keccak256("system.TreasureEffectLinearDamage")),
                effectName: "Missile",
                effectAsset: "missile",
                effectGroup: 1,
                effectRarely: 60,
                energyPerArea: 20,
                energyPerValue: 40,
                useMode: 1,
                hitMode: 0,
                basicCooldownTime: 10,//10s
                energyPerRange: 10,
                basicUsageTimes: 10,
                minArea: 1,
                maxArea: 3,
                minValue: 1,
                maxValue: 1
            }),
            InnerTreasureEffectConfig({
                effectID: uint256(keccak256("system.TreasureEffectNegativeAddHP")),
                effectName: "External blood package",
                effectAsset: "blood_package",
                effectGroup: 0,
                effectRarely: 60,
                energyPerArea: 10,
                energyPerValue: 100,
                useMode: 0,
                hitMode: 0,
                basicCooldownTime: 86400,//1 day
                energyPerRange: 0,
                basicUsageTimes: 5,
                minArea: 1,
                maxArea: 1,
                minValue: 1,
                maxValue: 2
            }),
            InnerTreasureEffectConfig({
                effectID: uint256(keccak256("system.TreasureEffectAirdropResource")),
                effectName: "Automated Resource Mine",
                effectAsset: "resource_miner",
                effectGroup: 1,
                effectRarely: 20,
                energyPerArea: 10,
                energyPerValue: 50,
                useMode: 1,
                hitMode: 1,
                basicCooldownTime: 86400,
                energyPerRange: 20,
                basicUsageTimes: 1,
                minArea: 1,
                maxArea: 1,
                minValue: 1,
                maxValue: 2
            }),
            InnerTreasureEffectConfig({
                effectID: uint256(keccak256("system.TreasureEffectDeathKeepResource")),
                effectName: "Secret Coffer",
                effectAsset: "secret_coffer",
                effectGroup: 2,
                effectRarely: 60,
                energyPerArea: 0,
                energyPerValue: 10,
                useMode: 0,
                hitMode: 0,
                basicCooldownTime: 10000,//10s
                energyPerRange: 10,
                basicUsageTimes: 1,
                minArea: 1,
                maxArea: 1,
                minValue: 1,
                maxValue: 1
            })
        ];

        for (uint i = 0; i < treasureEffectConfigs.length; i++) {
            InnerTreasureEffectConfig memory config = treasureEffectConfigs[i];
            uint256 uid = world.getUniqueEntityId();
            treasureEffectConfigRegister.set(uid, config.effectGroup);
            treasureEffectConfig.set(uid, TreasureEffectConfig({
                effectID: config.effectID,
                effectName: config.effectName,
                effectAsset: config.effectAsset,
                effectGroup: config.effectGroup,
                effectRarely: config.effectRarely,
                useMode: config.useMode,
                hitMode: config.hitMode
            }));
            treasureEffectGenerateConfig.set(uid, TreasureEffectGenerateConfig({
                energyPerArea: config.energyPerArea,
                energyPerValue: config.energyPerValue,
                basicCooldownTime: config.basicCooldownTime,
                energyPerRange: config.energyPerRange,
                basicUsageTimes: config.basicUsageTimes,
                minArea: config.minArea,
                maxArea: config.maxArea,
                minValue: config.minValue,
                maxValue: config.maxValue
            }));
        }
    }

    function setTreasureEffectGlobalConfigs(IWorld world) internal {
        TreasureEffectGlobalConfigComponent treasureEffectGlobalConfig = TreasureEffectGlobalConfigComponent(
            world.getComponent(TreasureEffectGlobalConfigComponentID)
        );
        uint32[2] memory effectGroupSource = [uint32(0), uint32(1)];//0-negative, 1-active
        uint64[2] memory effectGroupRarelySource = [uint64(40), uint64(60)];
        string[2] memory effectGroupNameSource = ["Passive", "Active"];
        uint32[] memory effectGroups = new uint32[](effectGroupSource.length);
        uint64[] memory effectGroupRarely = new uint64[](effectGroupSource.length);
        string[] memory effectGroupName = new string[](effectGroupSource.length);
        for (uint i = 0; i < effectGroupSource.length; i++) {
            effectGroups[i] = effectGroupSource[i];
            effectGroupRarely[i] = effectGroupRarelySource[i];
            effectGroupName[i] = effectGroupNameSource[i];
        }
        treasureEffectGlobalConfig.set(TreasureEffectGlobalConfig({
            effectGroups: effectGroups,
            effectGroupRarely: effectGroupRarely,
            effectGroupName: effectGroupName,
            minEnergy: 100,
            maxEnergy: 200
        }));
    }
}
