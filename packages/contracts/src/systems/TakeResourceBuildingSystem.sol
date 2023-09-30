// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "ResourceMiningv2Component", "Resourcev2Component"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ResourceConfigv2Component, ID as ResourceConfigv2ComponentID, ResourceConfig} from "components/ResourceConfigv2Component.sol";
// import { MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig } from "components/MoveConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {SpaceTimeMarkerComponent, ID as SpaceTimeMarkerComponentID, SpaceTimeMarker} from "components/SpaceTimeMarkerComponent.sol";

// import {ResourcePositionComponent, ID as ResourcePositionComponentID} from "components/ResourcePositionComponent.sol";
import {BuffComponent, ID as BuffComponentID, Buff} from "components/BuffComponent.sol";
import {BuffBelongingComponent, ID as BuffBelongingComponentID} from "components/BuffBelongingComponent.sol";
import {ResourceBuildingPlayerComponent, ID as ResourceBuildingPlayerComponentID} from "components/ResourceBuildingPlayerComponent.sol";
import {ResourceBuildingPositionComponent, ID as ResourceBuildingPositionComponentID} from "components/ResourceBuildingPositionComponent.sol";
import {ResourceBuildingComponent, ID as ResourceBuildingComponentID, ResourceBuilding} from "components/ResourceBuildingComponent.sol";
import {ResourceBuildingAreaPositionComponent, ID as ResourceBuildingAreaPositionComponentID} from "components/ResourceBuildingAreaPositionComponent.sol";
import {ResourceBuildingAreaBuildingComponent, ID as ResourceBuildingAreaBuildingComponentID} from "components/ResourceBuildingAreaBuildingComponent.sol";
import {ResourceMiningv2Component, ID as ResourceMiningv2ComponentID, ResourceMining} from "components/ResourceMiningv2Component.sol";
import {Resourcev2Component, ID as Resourcev2ComponentID, Resource} from "components/Resourcev2Component.sol";
// import {PlayerComponent, ID as PlayerComponentID} from "components/PlayerComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
// import {WarshipComponent, ID as WarshipComponentID, Warship} from "components/WarshipComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {IResourceVerifier} from "verifiers/ResourceVerifierv2.sol";

uint256 constant ID = uint256(keccak256("system.TakeResourceBuilding"));

struct TakeInfo {
    uint256 realHash;
    uint256 fogHash;
    uint256 width;
    uint256 height;
    uint256 terrainSeed;
    uint256 fogSeed;
    uint256 resourceSeed;
    uint256 terrainPerlin;
    uint256 resourcePerlin;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    uint256 resourceBuildingId;
}

contract TakeResourceBuildingSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        TakeInfo memory takeInfo = abi.decode(args, (TakeInfo));
        return executeTyped(takeInfo);
    }

    function executeTyped(
        TakeInfo memory takeInfo
    ) public returns (bytes memory) {
        ZKConfig memory zkConfig = ZKConfigComponent(
            getAddressById(components, ZKConfigComponentID)
        ).getValue();
        if (zkConfig.open) {
            uint256[9] memory input = [takeInfo.realHash, takeInfo.fogHash, takeInfo.terrainSeed, takeInfo.fogSeed, takeInfo.resourceSeed, takeInfo.terrainPerlin, takeInfo.resourcePerlin, takeInfo.width, takeInfo.height];
            require(
                IResourceVerifier(zkConfig.resourceVerifyv2Address).verifyProof(
                    takeInfo.a,
                    takeInfo.b,
                    takeInfo.c,
                    input
                ),
                "Failed resource proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);
        require(takeInfo.fogHash == HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).getValue(entityId), "not standing on resource");

        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            takeInfo.width <= mapConfig.gameRadiusX &&
                takeInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        checkSpaceTimeMark(takeInfo.realHash, takeInfo.fogSeed);
        // MoveCooldown memory movable = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).getValue(entityId);
        // MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
        // require(
        //     movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
        //     "no action points"
        // );
        uint256 resourceId = takeInfo.resourceBuildingId;
        ResourceMiningv2Component resourceMining = ResourceMiningv2Component(
            getAddressById(components, ResourceMiningv2ComponentID)
        );
        uint32 resourceBuildingValue = resourceBuildingValid(takeInfo.resourceBuildingId, takeInfo.fogHash);
        (uint256 remain, uint256 cache, uint256 diff) = getRemainAndCache(takeInfo.resourceBuildingId, uint256(keccak256(abi.encode(takeInfo.resourcePerlin))), resourceBuildingValue);
        if (cache >= 0) {
            GoldAmountComponent goldAmount = GoldAmountComponent(
                getAddressById(components, GoldAmountComponentID)
            );
            if (goldAmount.has(entityId)) {
                cache = cache + goldAmount.getValue(entityId);
            }
            resourceMining.set(resourceId, ResourceMining({remain: remain, cache: 0, lastMineTime: uint64(block.timestamp)}));
            goldAmount.set(entityId, cache);
        }
    }

    function checkSpaceTimeMark(uint256 realCoord, uint256 fogSeed) internal {
        SpaceTimeMarkerComponent spaceTimeMarker = SpaceTimeMarkerComponent(
            getAddressById(components, SpaceTimeMarkerComponentID)
        );
        require(spaceTimeMarker.has(realCoord), "coord not marked");
        SpaceTimeMarker memory mark = spaceTimeMarker.getValue(realCoord);
        require(mark.seed == uint32(fogSeed) && (mark.isUnlimited || (!mark.isUnlimited && mark.timeout >= uint64(block.timestamp))), "fog seed invalid");
    }

    function resourceBuildingValid(uint256 resourceBuildingId, uint256 fogHash) internal returns (uint32) {
        // uint256 entityId = addressToEntity(msg.sender);
        // ResourceBuildingPlayerComponent resourceBuildingPlayer = ResourceBuildingPlayerComponent(
        //     getAddressById(components, ResourceBuildingPlayerComponentID)
        // );
        // require(resourceBuildingPlayer.has(resourceBuildingId) && resourceBuildingPlayer.getValue(resourceBuildingId) == entityId, "invalid resource building");
        ResourceBuildingPositionComponent resourceBuildingPosition = ResourceBuildingPositionComponent(
            getAddressById(components, ResourceBuildingPositionComponentID)
        );
        require(resourceBuildingPosition.has(resourceBuildingId) && resourceBuildingPosition.getValue(resourceBuildingId) == fogHash, "invalid perlin position");
        ResourceBuildingComponent resourceBuildingComponent = ResourceBuildingComponent(
            getAddressById(components, ResourceBuildingComponentID)
        );
        ResourceBuilding memory resourceBuilding = resourceBuildingComponent.getValue(resourceBuildingId);
        require(resourceBuilding.timeout == 0 || resourceBuilding.timeout > block.timestamp, "resourceBuilding timeout");
        return resourceBuilding.value;
    }

    function getRemainAndCache(uint256 resourceBuildingId, uint256 perlin, uint32 resourceBuildingValue) internal returns (uint256 remain, uint256 cache, uint256 diff) {
        ResourceMiningv2Component resourceMining = ResourceMiningv2Component(
            getAddressById(components, ResourceMiningv2ComponentID)
        );
        Resourcev2Component resource = Resourcev2Component(
            getAddressById(components, Resourcev2ComponentID)
        );
        remain = 0;
        cache = 0;
        diff = 0;
        uint256 value = 0;
        uint64 recuitSeconds = 1;
        if (!resource.has(resourceBuildingId)) {
            ResourceConfig memory resourceConfig = ResourceConfigv2Component(
                getAddressById(components, ResourceConfigv2ComponentID)
            ).getValue();
            value = perlin % (resourceConfig.valueMax - resourceConfig.valueMin) + resourceConfig.valueMin;
            diff = uint8(perlin / (resourceConfig.valueMax - resourceConfig.valueMin)) % (resourceConfig.difficultMax - resourceConfig.difficultMin) + resourceConfig.difficultMin;
            recuitSeconds = uint64(perlin / (resourceConfig.valueMax - resourceConfig.valueMin) / uint256(resourceConfig.difficultMax - resourceConfig.difficultMin)) % (resourceConfig.recuitTimeMax - resourceConfig.recuitTimeMin) + resourceConfig.recuitTimeMin;
            if (diff > resourceBuildingValue) {
                diff = diff - uint8(resourceBuildingValue);
            } else {
                diff = 1;
            }
            resource.set(resourceBuildingId, Resource({value: value, difficulty: diff, recuitSeconds: recuitSeconds }));
            remain = value;
        } else {
            Resource memory resourceValue = resource.getValue(resourceBuildingId);
            value = resourceValue.value;
            diff = resourceValue.difficulty;
            recuitSeconds = resourceValue.recuitSeconds;
        }
        if (resourceMining.has(resourceBuildingId)) {
            ResourceMining memory miningState = resourceMining.getValue(resourceBuildingId);
            remain = miningState.remain;
            cache = miningState.cache;
            if (recuitSeconds > 0) {
                uint256 adds = uint256((uint64(block.timestamp) - miningState.lastMineTime) / recuitSeconds);
                if (remain + adds >= value) {
                    remain = value;
                } else {
                    remain = remain + adds;
                }
            }
        }
        return (remain, cache, diff);
    }

    function updateDifficulty(uint256 resourceBuildingId, uint256 diff) internal returns (uint256 newDiff) {
        newDiff = checkNearbyResourceBuildings(resourceBuildingId, diff);
        newDiff = checkBuffs(diff);
        return newDiff;
    }

    function checkNearbyResourceBuildings(uint256 resourceBuildingId, uint256 diff) internal returns (uint256 newDiff) {
        newDiff = diff;
        uint256 entityId = addressToEntity(msg.sender);
        ResourceBuildingAreaPositionComponent resourceBuildingAreaPosition = ResourceBuildingAreaPositionComponent(
            getAddressById(components, ResourceBuildingAreaPositionComponentID)
        );
        ResourceBuildingAreaBuildingComponent resourceBuildingAreaBuilding = ResourceBuildingAreaBuildingComponent(
            getAddressById(components, ResourceBuildingAreaBuildingComponentID)
        );
        ResourceBuildingPlayerComponent resourceBuildingPlayer = ResourceBuildingPlayerComponent(
            getAddressById(components, ResourceBuildingPlayerComponentID)
        );
        ResourceBuildingPositionComponent resourceBuildingPosition = ResourceBuildingPositionComponent(
            getAddressById(components, ResourceBuildingPositionComponentID)
        );
        // nearbyResourceBuildings
        uint8 count = 0;
        uint256[] memory nearbyHashs = resourceBuildingAreaBuilding.getEntitiesWithValue(resourceBuildingId);
        // for (uint256 index1 = 0; index1 < buildingsToCheck.length; index1++) {
        for (uint256 index = 0; index < nearbyHashs.length; index++) {
            if (resourceBuildingAreaPosition.has(nearbyHashs[index])) {
                uint256[] memory resourceBuildings = resourceBuildingPosition.getEntitiesWithValue(resourceBuildingAreaPosition.getValue(nearbyHashs[index]));
                if (resourceBuildings.length > 0) {
                    uint256 nearbyId = resourceBuildings[0];
                    if (resourceBuildingPlayer.has(nearbyId) && resourceBuildingPlayer.getValue(nearbyId) == entityId) {
                        count = count + uint8(1);
                    }
                }
            }
        }
        // uint256[] memory nearbyResourceBuildings = new uint256[](diff - 1);
        // uint256[] memory buildingsToCheck = new uint256[](diff - 1);
        // buildingsToCheck[0] = resourceBuildingId;
        // for (uint256 index = 0; index < (diff - 1); index++) {
        //     bool found = false;
        //     for (uint256 index1 = 0; index1 < buildingsToCheck.length; index1++) {
        //         uint256[] memory nearbyHashs = resourceBuildingAreaBuilding.getEntitiesWithValue(resourceBuildingId);
        //         for (uint256 index2 = 0; index2 < nearbyHashs.length; index2++) {
        //             if (resourceBuildingAreaPosition.has(nearbyHashs[index2])) {
        //                 uint256[] memory resourceBuildings = resourceBuildingPosition.getEntitiesWithValue(resourceBuildingAreaPosition.getValue(nearbyHashs[index2]));
        //                 if (resourceBuildings.length > 0) {}
        //             }
        //         }
        //     }
        // }
        if (newDiff > count) {
            newDiff = newDiff - count;
        } else {
            newDiff = 1;
        }
        return newDiff;
    }

    function checkBuffs(uint256 diff) internal returns (uint256 newDiff) {
        uint256 entityId = addressToEntity(msg.sender);
        BuffBelongingComponent buffBelonging = BuffBelongingComponent(
            getAddressById(components, BuffBelongingComponentID)
        );
        BuffComponent buffComponent = BuffComponent(getAddressById(components, BuffComponentID));
        uint256[] memory buffIds = buffBelonging.getEntitiesWithValue(entityId);
        newDiff = diff;
        for (uint256 index = 0; index < buffIds.length; index++) {
            if (buffComponent.has(buffIds[index])) {
                Buff memory buff = buffComponent.getValue(buffIds[index]);
                if ((buff.buffTimeout == 0 || buff.buffTimeout >= block.timestamp) && buff.targetID == ID) {
                    if (buff.isAdd) {
                        newDiff = newDiff + uint8(buff.buffValue);
                    } else {
                        newDiff = newDiff - uint8(buff.buffValue);
                    }
                }
            }
        }
        return newDiff;
    }
}
