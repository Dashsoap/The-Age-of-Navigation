// SPDX-License-Identifier: MIT
// components: ["SpaceTimeMarkerComponent", "ResourceNonceMarkComponent", "ResourceMiningv2Component", "Resourcev2Component", "GoldAmountComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ResourceConfigv2Component, ID as ResourceConfigv2ComponentID, ResourceConfig} from "components/ResourceConfigv2Component.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";

// import {ResourcePositionComponent, ID as ResourcePositionComponentID} from "components/ResourcePositionComponent.sol";
import {ResourceMiningv2Component, ID as ResourceMiningv2ComponentID, ResourceMining} from "components/ResourceMiningv2Component.sol";
import {Resourcev2Component, ID as Resourcev2ComponentID, Resource} from "components/Resourcev2Component.sol";
import {SpaceTimeMarkerComponent, ID as SpaceTimeMarkerComponentID, SpaceTimeMarker} from "components/SpaceTimeMarkerComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {ResourceNonceMarkComponent, ID as ResourceNonceMarkComponentID} from "components/ResourceNonceMarkComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {IResourceVerifier} from "verifiers/ResourceVerifierv2.sol";

uint256 constant ID = uint256(keccak256("system.DigResourcev2"));

struct DigInfo {
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
    uint256[] powNonces;
}

contract DigResourcev2System is System {
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
            uint256[9] memory input = [digInfo.realHash, digInfo.fogHash, digInfo.terrainSeed, digInfo.fogSeed, digInfo.resourceSeed, digInfo.terrainPerlin, digInfo.resourcePerlin, digInfo.width, digInfo.height];
            require(
                IResourceVerifier(zkConfig.resourceVerifyv2Address).verifyProof(
                    digInfo.a,
                    digInfo.b,
                    digInfo.c,
                    input
                ),
                "Failed resource proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);
        require(digInfo.fogHash == HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).getValue(entityId), "not standing on resource");

        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            digInfo.width <= mapConfig.gameRadiusX &&
                digInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        if (mapConfig.treasureDifficulty >= mapConfig.resourceDifficulty) {
            require(
                (digInfo.terrainPerlin >= 7500 && digInfo.realHash % 2 ** mapConfig.resourceDifficulty == 0 && digInfo.realHash % 2 ** mapConfig.treasureDifficulty > 0),
                "no resource to dig"
            );
        } else {
            require(
                (digInfo.terrainPerlin >= 7500 && digInfo.realHash % 2 ** mapConfig.resourceDifficulty == 0),
                "no resource to dig"
            );
        }
        setSpaceTimeMark(digInfo.realHash, digInfo.fogSeed);
        // ResourcePositionComponent resourcePosition = ResourcePositionComponent(
        //     getAddressById(components, ResourcePositionComponentID)
        // );
        // uint256[] memory resourceIds =  resourcePosition.getEntitiesWithValue(digInfo.coordHash);
        
        uint256 resourceId = digInfo.fogHash;
        // if (resourceIds.length > 0) {
        //     resourceId = resourceIds[0];
        // }
        // if (resourceId == 0) {
        //     resourceId = world.getUniqueEntityId();
        // }
        // Resourcev2Component resource = Resourcev2Component(
        //     getAddressById(components, Resourcev2ComponentID)
        // );
        ResourceMiningv2Component resourceMining = ResourceMiningv2Component(
            getAddressById(components, ResourceMiningv2ComponentID)
        );
        (uint256 remain, uint256 cache, uint256 difficulty) = getRemainAndCache(resourceId, digInfo.resourcePerlin);
        uint256 amount = checkPowNonces(digInfo.fogHash, digInfo.powNonces, difficulty);
        require(remain >= amount, "remain value too low");
        markPowNonces(digInfo.fogHash, digInfo.powNonces);
        // resourceMining.set(resourceId, ResourceMining({remain: remain-amount, cache: cache+amount, lastMineTime: uint64(block.timestamp)}));
        resourceMining.set(resourceId, ResourceMining({remain: remain-amount, cache: cache, lastMineTime: uint64(block.timestamp)}));
        GoldAmountComponent goldAmount = GoldAmountComponent(
            getAddressById(components, GoldAmountComponentID)
        );
        uint256 cache1 = amount;
        if (goldAmount.has(entityId)) {
            cache1 = cache1 + goldAmount.getValue(entityId);
        }
        goldAmount.set(entityId, cache1);
    }

    function checkPowNonces(uint256 fogHash, uint256[] memory powNonces, uint256 difficulty) internal returns (uint256 amount) {
        ResourceConfig memory resourceConfig = ResourceConfigv2Component(
            getAddressById(components, ResourceConfigv2ComponentID)
        ).getValue();
        uint256 totalLength = powNonces.length;
        require(totalLength <= resourceConfig.maxBatch, "powNonces over limit");
        ResourceNonceMarkComponent resourceNonceMark = ResourceNonceMarkComponent(
            getAddressById(components, ResourceNonceMarkComponentID)
        );
        for (uint256 index = 0; index < totalLength; index++) {
            uint256 powNonce = powNonces[index];
            uint256 powResult = uint256(keccak256(abi.encodePacked(fogHash, powNonce)));
            require(powResult % 2 ** difficulty == 0 && !resourceNonceMark.has(powResult), "pow value invalid");
            amount = amount + 1;
        }
        return amount;
    }

    function markPowNonces(uint256 fogHash, uint256[] memory powNonces) internal {
        ResourceNonceMarkComponent resourceNonceMark = ResourceNonceMarkComponent(
            getAddressById(components, ResourceNonceMarkComponentID)
        );
        for (uint256 index = 0; index < powNonces.length; index++) {
            uint256 powNonce = powNonces[index];
            uint256 powResult = uint256(keccak256(abi.encodePacked(fogHash, powNonce)));
            resourceNonceMark.set(powResult, fogHash);
        }
    }

    function setSpaceTimeMark(uint256 realCoord, uint256 fogSeed) internal {
        SpaceTimeMarkerComponent spaceTimeMarker = SpaceTimeMarkerComponent(
            getAddressById(components, SpaceTimeMarkerComponentID)
        );
        if (spaceTimeMarker.has(realCoord)) {
            SpaceTimeMarker memory mark = spaceTimeMarker.getValue(realCoord);
            require(mark.seed == uint32(fogSeed) && (mark.isUnlimited || (!mark.isUnlimited && mark.timeout >= uint64(block.timestamp))), "fog seed invalid");
            if (mark.seed == uint32(fogSeed) && mark.isUnlimited) {
                return;
            }
            spaceTimeMarker.set(realCoord, SpaceTimeMarker(uint32(fogSeed), 0, true));
        } else {
            require(FogSeedComponent(world.getComponent(FogSeedComponentID)).getValue() == uint32(fogSeed), "fog seed invalid");
            spaceTimeMarker.set(realCoord, SpaceTimeMarker(uint32(fogSeed), 0, true));
        }
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
