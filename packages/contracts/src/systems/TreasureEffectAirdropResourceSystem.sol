// SPDX-License-Identifier: MIT
// components: ["ResourceBuildingPlayerComponent", "ResourceBuildingPositionComponent", "ResourceBuildingAreaPositionComponent", "ResourceBuildingAreaBuildingComponent", "ResourceBuildingComponent", "SpaceTimeMarkerComponent", "HPComponent", "HPLimitComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";

import {HPComponent, ID as HPComponentID} from "components/HPComponent.sol";
import {HPLimitComponent, ID as HPLimitComponentID} from "components/HPLimitComponent.sol";
import {ResourceBuildingPlayerComponent, ID as ResourceBuildingPlayerComponentID} from "components/ResourceBuildingPlayerComponent.sol";
import {ResourceBuildingPositionComponent, ID as ResourceBuildingPositionComponentID} from "components/ResourceBuildingPositionComponent.sol";
import {ResourceBuildingAreaPositionComponent, ID as ResourceBuildingAreaPositionComponentID} from "components/ResourceBuildingAreaPositionComponent.sol";
import {ResourceBuildingAreaBuildingComponent, ID as ResourceBuildingAreaBuildingComponentID} from "components/ResourceBuildingAreaBuildingComponent.sol";
import {ResourceBuildingComponent, ID as ResourceBuildingComponentID, ResourceBuilding} from "components/ResourceBuildingComponent.sol";
import {SpaceTimeMarkerComponent, ID as SpaceTimeMarkerComponentID, SpaceTimeMarker} from "components/SpaceTimeMarkerComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.TreasureEffectAirdropResource"));
// uint256 constant BuffID = uint256(keccak256("system.BuffEffectAddHPCalculateSystem"));

contract TreasureEffectAirdropResourceSystem is TreasureEffectSystem {
    event Debug(string prex, uint256 value);

    constructor(
        IWorld _world,
        address _components
    ) TreasureEffectSystem(_world, _components) {}

    function effectLogic(
        TreasureEffectInfo memory effectInfo
    ) internal override returns (bytes memory) {
        uint256 entityId = effectInfo.entity;
        uint256 resourceBuildingId = world.getUniqueEntityId();
        // check ResourceBuildingPosition(path[0])
        emit Debug("path:", effectInfo.path.length);
        emit Debug("area:", effectInfo.area.length);
        require(effectInfo.path.length == 1, "target coord invalid");
        checkResourceBuildingPosition(effectInfo.path[0].fogHash);
        checkSpaceTimeMark(effectInfo.path[0].realHash, effectInfo.path[0].fogSeed);
        // airdrop defense area
        // create ShieldArea entities
        for (uint256 index = 0; index < effectInfo.area.length; index++) {
            emit Debug("checking:", effectInfo.area[index].fogHash);
            CoordVerifyParam memory coord = effectInfo.area[index];
            checkCoordZK(coord, components);
            checkSpaceTimeMark(coord.realHash, coord.fogSeed);
        }
        emit Debug("adding resourceBuilding:", effectInfo.path[0].fogHash);
        setResourceBuildingPosition(effectInfo.path[0].fogHash, resourceBuildingId);
        setSpaceTimeMark(effectInfo.path[0].realHash, effectInfo.path[0].fogSeed);
        for (uint256 index1 = 0; index1 < effectInfo.area.length; index1++) {
            emit Debug("adding effect area:", effectInfo.area[index1].fogHash);
            CoordVerifyParam memory coord1 = effectInfo.area[index1];
            setSpaceTimeMark(coord1.realHash, coord1.fogSeed);
            setResourceBuildingArea(coord1, resourceBuildingId);
        }
        // create Shield entity
        emit Debug("resourceBuilding value:", effectInfo.value);
        setResourceBuilding(entityId, effectInfo.value, uint64(0), resourceBuildingId);
    }

    function checkResourceBuildingPosition(uint256 fogCoord) internal {
        ResourceBuildingPositionComponent resourceBuildingPositionComponent = ResourceBuildingPositionComponent(
            getAddressById(components, ResourceBuildingPositionComponentID)
        );
        uint256[] memory entities = resourceBuildingPositionComponent.getEntitiesWithValue(fogCoord);
        require(entities.length == 0, "has Entity in target coord");
    }

    function checkSpaceTimeMark(uint256 realCoord, uint256 fogSeed) internal {
        SpaceTimeMarkerComponent spaceTimeMarker = SpaceTimeMarkerComponent(
            getAddressById(components, SpaceTimeMarkerComponentID)
        );
        if (spaceTimeMarker.has(realCoord)) {
            SpaceTimeMarker memory mark = spaceTimeMarker.getValue(realCoord);
            require(mark.seed == uint32(fogSeed) && (mark.isUnlimited || (!mark.isUnlimited && mark.timeout >= uint64(block.timestamp))), "fog seed invalid");
        } else {
            require(FogSeedComponent(world.getComponent(FogSeedComponentID)).getValue() == uint32(fogSeed), "fog seed invalid");
        }
    }

    function setSpaceTimeMark(uint256 realCoord, uint256 fogSeed) internal {
        SpaceTimeMarkerComponent spaceTimeMarker = SpaceTimeMarkerComponent(
            getAddressById(components, SpaceTimeMarkerComponentID)
        );
        spaceTimeMarker.set(realCoord, SpaceTimeMarker(uint32(fogSeed), 0, true));
    }

    function setResourceBuildingArea(CoordVerifyParam memory coord, uint256 resourceBuildingId) internal {
        uint256 resourceBuildingAreaId = world.getUniqueEntityId();
        ResourceBuildingAreaPositionComponent(
            getAddressById(components, ResourceBuildingAreaPositionComponentID)
        ).set(resourceBuildingAreaId, coord.fogHash);
        ResourceBuildingAreaBuildingComponent(
            getAddressById(components, ResourceBuildingAreaBuildingComponentID)
        ).set(resourceBuildingAreaId, resourceBuildingId);
    }

    function setResourceBuildingPosition(uint256 fogCoord, uint256 resourceBuildingId) internal {
        ResourceBuildingPositionComponent resourceBuildingPositionComponent = ResourceBuildingPositionComponent(
            getAddressById(components, ResourceBuildingPositionComponentID)
        );
        resourceBuildingPositionComponent.set(resourceBuildingId, fogCoord);
    }

    function setResourceBuilding(uint256 entityId, uint32 value, uint64 timeout, uint256 resourceBuildingId) internal {
        ResourceBuildingComponent(
            getAddressById(components, ResourceBuildingComponentID)
        ).set(resourceBuildingId, ResourceBuilding({ value: value, timeout: timeout }));
        ResourceBuildingPlayerComponent(
            getAddressById(components, ResourceBuildingPlayerComponentID)
        ).set(resourceBuildingId, entityId);
        HPComponent(getAddressById(components, HPComponentID)).set(entityId, 2);
        HPLimitComponent(getAddressById(components, HPLimitComponentID)).set(entityId, 2);
    }
}
