// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "ResourceMiningComponent", "ResourceComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ResourceConfigComponent, ID as ResourceConfigComponentID, ResourceConfig} from "components/ResourceConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

// import {ResourcePositionComponent, ID as ResourcePositionComponentID} from "components/ResourcePositionComponent.sol";
import {ResourceMiningComponent, ID as ResourceMiningComponentID, ResourceMining} from "components/ResourceMiningComponent.sol";
import {ResourceComponent, ID as ResourceComponentID, Resource} from "components/ResourceComponent.sol";
// import {PlayerComponent, ID as PlayerComponentID} from "components/PlayerComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
// import {WarshipComponent, ID as WarshipComponentID, Warship} from "components/WarshipComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {IResourceVerifier} from "verifiers/ResourceVerifier.sol";

uint256 constant ID = uint256(keccak256("system.TakeResource"));

struct TakeInfo {
    uint256 coordHash;
    uint256 width;
    uint256 height;
    uint256 seed;
    uint256 resourceSeed;
    uint256 terrainPerlin;
    uint256 resourcePerlin;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    uint256 remain;
    uint256 cache;
}

contract TakeResourceSystem is System {
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
            uint256[7] memory input = [takeInfo.coordHash, takeInfo.seed, takeInfo.resourceSeed, takeInfo.terrainPerlin, takeInfo.resourcePerlin, takeInfo.width, takeInfo.height];
            require(
                IResourceVerifier(zkConfig.resourceVerifyAddress).verifyProof(
                    takeInfo.a,
                    takeInfo.b,
                    takeInfo.c,
                    input
                ),
                "Failed resource proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);
        require(takeInfo.coordHash == HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).getValue(entityId), "not standing on resource");

        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            takeInfo.width <= mapConfig.gameRadiusX &&
                takeInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        require(
            // hash <= resourceDifficulty <= resourceDifficulty || resourceDifficulty < hash <= resourceDifficulty
            (takeInfo.coordHash <= mapConfig.resourceDifficulty &&
                mapConfig.resourceDifficulty <= mapConfig.resourceDifficulty) || (takeInfo.coordHash <= mapConfig.resourceDifficulty &&
                takeInfo.coordHash > mapConfig.resourceDifficulty),
            "no resource to take"
        );
        // ResourcePositionComponent resourcePosition = ResourcePositionComponent(
        //     getAddressById(components, ResourcePositionComponentID)
        // );
        // uint256[] memory resourceIds =  resourcePosition.getEntitiesWithValue(takeInfo.coordHash);
        uint256 resourceId = takeInfo.coordHash;
        // if (resourceIds.length > 0) {
        //     resourceId = resourceIds[0];
        // }
        // if (resourceId == 0) {
        //     resourceId = world.getUniqueEntityId();
        // }
        // ResourceComponent resource = ResourceComponent(
        //     getAddressById(components, ResourceComponentID)
        // );
        ResourceMiningComponent resourceMining = ResourceMiningComponent(
            getAddressById(components, ResourceMiningComponentID)
        );
        (uint256 remain, uint256 cache, uint256 difficulty) = getRemainAndCache(resourceId, takeInfo.resourcePerlin);
        require(remain == takeInfo.remain && cache == takeInfo.cache, "remain value invalid");
        // resourcePosition.set(resourceId, takeInfo.coordHash);
        if (cache >= 0) {
            GoldAmountComponent goldAmount = GoldAmountComponent(
                getAddressById(components, GoldAmountComponentID)
            );
            if (goldAmount.has(entityId)) {
                cache = cache + goldAmount.getValue(entityId);
            }
            resourceMining.set(resourceId, ResourceMining({remain: remain, cache: 0}));
            goldAmount.set(entityId, cache);
        }
    }

    function getRemainAndCache(uint256 resourceId, uint256 perlin) internal returns (uint256 remain, uint256 cache, uint256 diff) {
        ResourceComponent resource = ResourceComponent(
            getAddressById(components, ResourceComponentID)
        );
        ResourceMiningComponent resourceMining = ResourceMiningComponent(
            getAddressById(components, ResourceMiningComponentID)
        );
        remain = 0;
        cache = 0;
        diff = 0;
        if (resourceMining.has(resourceId)) {
            diff = resource.getValue(resourceId).difficulty;
            ResourceMining memory miningState = resourceMining.getValue(resourceId);
            remain = miningState.remain;
            cache = miningState.cache;
        }
        if (!resource.has(resourceId)) {
            ResourceConfig memory resourceConfig = ResourceConfigComponent(
                getAddressById(components, ResourceConfigComponentID)
            ).getValue();
            uint256 value = perlin % (resourceConfig.valueMax - resourceConfig.valueMin) + resourceConfig.valueMin;
            diff = uint8(perlin / (resourceConfig.valueMax - resourceConfig.valueMin)) % (resourceConfig.difficultMax - resourceConfig.difficultMin) + resourceConfig.difficultMin;
            resource.set(resourceId, Resource({value: value, difficulty: diff}));
            remain = value;
        }
        return (remain, cache, diff);
    }
}
