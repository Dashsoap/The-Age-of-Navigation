// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {ResourceConfigv2Component, ID as ResourceConfigv2ComponentID, ResourceConfig} from "components/ResourceConfigv2Component.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

library ResourceConfigv2Initializer {
    function init(IWorld world) internal {
        ResourceConfigv2Component resourceConfig = ResourceConfigv2Component(
            world.getComponent(ResourceConfigv2ComponentID)
        );
        resourceConfig.set(ResourceConfig({ valueMax: 200, valueMin: 50, difficultMax: 8, difficultMin: 4, recuitTimeMax: 3600, recuitTimeMin: 60, maxBatch: 50 }));
    }
}
