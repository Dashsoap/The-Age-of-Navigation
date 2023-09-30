// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {ResourceConfigComponent, ID as ResourceConfigComponentID, ResourceConfig} from "components/ResourceConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

library ResourceConfigInitializer {
    function init(IWorld world) internal {
        ResourceConfigComponent treasureConfig = ResourceConfigComponent(
            world.getComponent(ResourceConfigComponentID)
        );
        treasureConfig.set(ResourceConfig({ valueMax: 200, valueMin: 50, difficultMax: 2, difficultMin: 1 }));
    }
}
