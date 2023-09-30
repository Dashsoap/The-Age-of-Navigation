// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";
import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
import {TreasureDistributionComponent, ID as TreasureDistributionComponentID} from "components/TreasureDistributionComponent.sol";
import {TechComponent, ID as TechComponentID} from "components/TechComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

library MapConfigv2Initializer {
    function init(IWorld world) internal {
        MapConfigv2Component mapConfig = MapConfigv2Component(
            world.getComponent(MapConfigv2ComponentID)
        );
        MoveConfigComponent moveConfig = MoveConfigComponent(
            world.getComponent(MoveConfigComponentID)
        );
        VisionConfigComponent visionConfig = VisionConfigComponent(
            world.getComponent(VisionConfigComponentID)
        );
        TerrainComponent terrain = TerrainComponent(
            world.getComponent(TerrainComponentID)
        );
        FogSeedComponent fogSeed = FogSeedComponent(
            world.getComponent(FogSeedComponentID)
        );
        ResourceDistributionComponent resourceDistribution = ResourceDistributionComponent(
            world.getComponent(ResourceDistributionComponentID)
        );
        TreasureDistributionComponent treasureDistribution = TreasureDistributionComponent(
            world.getComponent(TreasureDistributionComponentID)
        );
        TechComponent tech = TechComponent(
            world.getComponent(TechComponentID)
        );
        terrain.set(uint32(11111));
        resourceDistribution.set(uint32(22222));
        treasureDistribution.set(uint32(33333));
        fogSeed.set(uint32(44444));

        mapConfig.set(
            MapConfig({
                resourceDifficulty: 1,
                treasureDifficulty: 2,
                gameOriginX: 5000,
                gameOriginY: 10000,
                gameRadiusX: 5000,
                gameRadiusY: 10000,
                decimals: 1
            })
        );
        moveConfig.set(
            MoveConfig({
                initPoints: 5,
                increaseCooldown: 1 * 60 * 60 * 1000,
                maxPoints: 10,
                maxDistance: 20,
                guildCost: 0
            })
        );
        visionConfig.set(
            VisionConfig({remainTime: 30, maxDistance: 30})
        );
    }
}
