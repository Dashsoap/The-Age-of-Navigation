// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "ResourceMiningComponent", "ResourceComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ResourceConfigComponent, ID as ResourceConfigComponentID, ResourceConfig} from "components/ResourceConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";

// import {ResourcePositionComponent, ID as ResourcePositionComponentID} from "components/ResourcePositionComponent.sol";
import {ResourceMiningComponent, ID as ResourceMiningComponentID, ResourceMining} from "components/ResourceMiningComponent.sol";
import {ResourceComponent, ID as ResourceComponentID, Resource} from "components/ResourceComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {IResourceVerifier} from "verifiers/ResourceVerifier.sol";

uint256 constant ID = uint256(keccak256("system.DigResource"));

struct DigInfo {
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
    uint256 powNonce;
}

contract DigResourceSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        DigInfo memory digInfo = abi.decode(args, (DigInfo));
        return executeTyped(digInfo);
    }

    function executeTyped(
        DigInfo memory digInfo
    ) public returns (bytes memory) {
        ZKConfig memory zkConfig = ZKConfigComponent(
            getAddressById(components, ZKConfigComponentID)
        ).getValue();
        if (zkConfig.open) {
            uint256[7] memory input = [digInfo.coordHash, digInfo.seed, digInfo.resourceSeed, digInfo.terrainPerlin, digInfo.resourcePerlin, digInfo.width, digInfo.height];
            require(
                IResourceVerifier(zkConfig.resourceVerifyAddress).verifyProof(
                    digInfo.a,
                    digInfo.b,
                    digInfo.c,
                    input
                ),
                "Failed resource proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);
        require(digInfo.coordHash == HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).getValue(entityId), "not standing on resource");

        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            digInfo.width <= mapConfig.gameRadiusX &&
                digInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        require(
            (digInfo.terrainPerlin >= 7500 && digInfo.coordHash / 16 ** (64 - mapConfig.resourceDifficulty) == 0 && digInfo.coordHash / 16 ** (64 - mapConfig.treasureDifficulty) > 0),
            "no resource to dig"
        );
        // ResourcePositionComponent resourcePosition = ResourcePositionComponent(
        //     getAddressById(components, ResourcePositionComponentID)
        // );
        // uint256[] memory resourceIds =  resourcePosition.getEntitiesWithValue(digInfo.coordHash);
        uint256 resourceId = digInfo.coordHash;
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
        (uint256 remain, uint256 cache, uint256 difficulty) = getRemainAndCache(resourceId, digInfo.resourcePerlin);
        require(remain == digInfo.remain && cache == digInfo.cache, "remain value invalid");
        uint256 powResult = uint256(keccak256(abi.encodePacked(digInfo.coordHash, digInfo.remain, digInfo.powNonce))); 
        require(powResult / 16 	** (64 - difficulty) == 0, "pow value invalid");
        // resourcePosition.set(resourceId, digInfo.coordHash);
        resourceMining.set(resourceId, ResourceMining({remain: remain-1, cache: cache}));
        GoldAmountComponent goldAmount = GoldAmountComponent(
            getAddressById(components, GoldAmountComponentID)
        );
        uint256 cache1 = 1;
        if (goldAmount.has(entityId)) {
            cache1 = cache1 + goldAmount.getValue(entityId);
        }
        goldAmount.set(entityId, cache1);
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
