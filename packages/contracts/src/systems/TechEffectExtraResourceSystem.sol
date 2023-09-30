// SPDX-License-Identifier: MIT
// components: ["TechEffectComponent", "TechEffectConfigRegisterComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";

import {TechEffectComponent, ID as TechEffectComponentID, TechEffect} from "components/TechEffectComponent.sol";
import {TechEffectConfigComponent, ID as TechEffectConfigComponentID, TechEffectConfig} from "components/TechEffectConfigComponent.sol";
import {TechEffectConfigRegisterComponent, ID as TechEffectConfigRegisterComponentID} from "components/TechEffectConfigRegisterComponent.sol";
import {TechEffectSystem, TechEffectInfo} from "expension/TechEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.TechEffectExtraResource"));
uint256 constant techEffectId = uint256(keccak256("system.TechEffect"));

contract TechEffectExtraResourceSystem is TechEffectSystem {
    constructor(
        IWorld _world,
        address _components
    ) TechEffectSystem(_world, _components) {}

    function effectLogic(
        TechEffectInfo memory techEffectInfo
    ) public override returns (bytes memory) {
        uint256 entityId = techEffectInfo.entity;
        uint256 buffId = world.getUniqueEntityId();
        //set buff for entity
        TechEffectComponent(
            getAddressById(components, TechEffectComponentID)
        ).set(buffId, TechEffect({
            techEffectId: techEffectInfo.techEffectId,
            techEffectLevel: 1,
            techEffectType: 2,
            buffValue: techEffectInfo.value,
            source: "techTreeUpdate"
        }));
        // TechEffectConfigRegisterComponent(
        //     getAddressById(components, TechEffectConfigRegisterComponentID)
        // ).set(buffId, entityId);
        // 然后通过在TakeResource里import本system来增加逻辑来实现每次拾取更多资源
    }
}
