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
import {ResourceMiningv2Component, ID as ResourceMiningv2ComponentID, ResourceMining} from "components/ResourceMiningv2Component.sol";
import {Resourcev2Component, ID as Resourcev2ComponentID, Resource} from "components/Resourcev2Component.sol";
// import {PlayerComponent, ID as PlayerComponentID} from "components/PlayerComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
// import {WarshipComponent, ID as WarshipComponentID, Warship} from "components/WarshipComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {IResourceVerifier} from "verifiers/ResourceVerifierv2.sol";

uint256 constant ID = uint256(keccak256("system.TakeResourcev2"));

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
}

contract TakeResourcev2System is System {
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
        if (mapConfig.treasureDifficulty >= mapConfig.resourceDifficulty) {
            require(
                (takeInfo.terrainPerlin >= 7500 && takeInfo.realHash % 2 ** mapConfig.resourceDifficulty == 0 && takeInfo.realHash % 2 ** mapConfig.treasureDifficulty > 0),
                "no resource to take"
            );
        } else {
            require(
                (takeInfo.terrainPerlin >= 7500 && takeInfo.realHash % 2 ** mapConfig.resourceDifficulty == 0),
                "no resource to take"
            );
        }
        checkSpaceTimeMark(takeInfo.realHash, takeInfo.fogSeed);
        // MoveCooldown memory movable = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).getValue(entityId);
        // MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
        // require(
        //     movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
        //     "no action points"
        // );
        uint256 resourceId = takeInfo.fogHash;
        ResourceMiningv2Component resourceMining = ResourceMiningv2Component(
            getAddressById(components, ResourceMiningv2ComponentID)
        );
        (uint256 remain, uint256 cache, uint256 difficulty) = getRemainAndCache(resourceId, takeInfo.resourcePerlin);
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

    function getRemainAndCache(uint256 resourceId, uint256 perlin) internal returns (uint256 remain, uint256 cache, uint256 diff) {
        Resourcev2Component resource = Resourcev2Component(
            getAddressById(components, Resourcev2ComponentID)
        );
        ResourceMiningv2Component resourceMining = ResourceMiningv2Component(
            getAddressById(components, ResourceMiningv2ComponentID)
        );
        remain = 0;
        cache = 0;
        diff = 0;
        uint256 value = 0;
        uint64 recuitSeconds = 1;
        if (!resource.has(resourceId)) {
            ResourceConfig memory resourceConfig = ResourceConfigv2Component(
                getAddressById(components, ResourceConfigv2ComponentID)
            ).getValue();
            value = perlin % (resourceConfig.valueMax - resourceConfig.valueMin) + resourceConfig.valueMin;
            diff = uint8(perlin / (resourceConfig.valueMax - resourceConfig.valueMin)) % (resourceConfig.difficultMax - resourceConfig.difficultMin) + resourceConfig.difficultMin;
            recuitSeconds = uint64(perlin / (resourceConfig.valueMax - resourceConfig.valueMin) / uint256(resourceConfig.difficultMax - resourceConfig.difficultMin)) % (resourceConfig.recuitTimeMax - resourceConfig.recuitTimeMin) + resourceConfig.recuitTimeMin;
            resource.set(resourceId, Resource({value: value, difficulty: diff, recuitSeconds: recuitSeconds }));
            remain = value;
        } else {
            Resource memory resourceValue = resource.getValue(resourceId);
            value = resourceValue.value;
            diff = resourceValue.difficulty;
            recuitSeconds = resourceValue.recuitSeconds;
        }
        if (resourceMining.has(resourceId)) {
            ResourceMining memory miningState = resourceMining.getValue(resourceId);
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
}
