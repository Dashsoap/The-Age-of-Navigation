// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {TechConfigComponent, ID as TechConfigComponentID, TechConfig} from "components/TechConfigComponent.sol";
import {TechEffectConfigComponent, ID as TechEffectConfigComponentID, TechEffectConfig} from "components/TechEffectConfigComponent.sol";
import {TechEffectConfigRegisterComponent, ID as TechEffectConfigRegisterComponentID} from "components/TechEffectConfigRegisterComponent.sol";
import {TechEffectComponent, ID as TechEffectComponentID, TechEffect} from "components/TechEffectComponent.sol";
import {TechBuildConfigComponent, ID as TechBuildConfigComponentID} from "components/TechBuildConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

import {TechEffectAddHPSystem} from "systems/TechEffectAddHPSystem.sol";
import {TechEffectExtraResourceSystem} from "systems/TechEffectExtraResourceSystem.sol";

struct InnerTechEffectConfig {
    string effectId;
    string effectName;
    uint32 effectGroup;
    uint64 effectRarely;
}

library TechEffectInitializer {
    function init(IWorld world) internal {
        // setTechEffectGlobalConfigs(world);
        TechBuildConfigComponent(
            world.getComponent(TechBuildConfigComponentID)
        ).set(1);
        TechEffectConfigComponent techEffectConfig = TechEffectConfigComponent(
            world.getComponent(TechEffectConfigComponentID)
        );
        TechEffectComponent techEffect = TechEffectComponent(
            world.getComponent(TechEffectComponentID)
        );
        TechEffectConfigRegisterComponent techEffectConfigRegister = TechEffectConfigRegisterComponent(
            world.getComponent(TechEffectConfigRegisterComponentID)
        );

        InnerTechEffectConfig[2] memory techEffectConfigs = [
            InnerTechEffectConfig({
                effectId: "system.TechEffectAddHP",
                effectName: "HP Enhancer",
                effectGroup: 1,
                effectRarely: 3
            }),
            InnerTechEffectConfig({
                effectId: "system.TechEffectExtraResource",
                effectName: "Reinforced Mining",
                effectGroup: 2,
                effectRarely: 3
            })
        ];

        for (uint i = 0; i < techEffectConfigs.length; i++) {
            InnerTechEffectConfig memory config = techEffectConfigs[i];
            uint256 uid = (uint256)(keccak256(abi.encodePacked(
                world.getUniqueEntityId(),
                config.effectId
            )));
            techEffectConfigRegister.set(uid, config.effectGroup);
            techEffectConfig.set(uid, TechEffectConfig({
                name: config.effectId,
                asset: config.effectName,
                techEffectType: config.effectGroup,
                buffRareType: config.effectRarely
            }));
            techEffect.set(uid, TechEffect({
                techEffectId: uid,
                techEffectLevel: 1,
                techEffectType: 1,
                buffValue: 0,
                source: "techTreeUpdate"
            }));
        }
    }
}
