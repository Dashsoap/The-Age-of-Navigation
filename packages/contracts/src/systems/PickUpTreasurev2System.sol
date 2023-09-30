// SPDX-License-Identifier: MIT
// components: ["TreasurePickedComponent", "Treasurev2Component", "TreasureTimerComponent", "PlayerBelongingComponent", "TreasureEffectv2Component", "SpaceTimeMarkerComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectConfigComponent, ID as TreasureEffectConfigComponentID, TreasureEffectConfig} from "components/TreasureEffectConfigComponent.sol";
import {TreasureEffectGenerateConfigComponent, ID as TreasureEffectGenerateConfigComponentID, TreasureEffectGenerateConfig} from "components/TreasureEffectGenerateConfigComponent.sol";
import {TreasureEffectConfigRegisterComponent, ID as TreasureEffectConfigRegisterComponentID} from "components/TreasureEffectConfigRegisterComponent.sol";
import {TreasureEffectGlobalConfigComponent, ID as TreasureEffectGlobalConfigComponentID, TreasureEffectGlobalConfig} from "components/TreasureEffectGlobalConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

import {PlayerBelongingComponent, ID as PlayerBelongingComponentID} from "components/PlayerBelongingComponent.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {TreasurePickedComponent, ID as TreasurePickedComponentID} from "components/TreasurePickedComponent.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
import {SpaceTimeMarkerComponent, ID as SpaceTimeMarkerComponentID, SpaceTimeMarker} from "components/SpaceTimeMarkerComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {ITreasureVerifier} from "verifiers/TreasureVerifierv2.sol";

uint256 constant ID = uint256(keccak256("system.PickUpTreasurev2"));

struct PickUpInfo {
    uint256 realHash;
    uint256 fogHash;
    uint256 width;
    uint256 height;
    uint256 terrainSeed;
    uint256 fogSeed;
    uint256 treasureSeed;
    uint256 terrainPerlin;
    uint256 treasurePerlin;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

contract PickUpTreasurev2System is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        PickUpInfo memory pickUpInfo = abi.decode(args, (PickUpInfo));
        return executeTyped(pickUpInfo);
    }

    function executeTyped(
        PickUpInfo memory pickUpInfo
    ) public returns (bytes memory) {
        ZKConfig memory zkConfig = ZKConfigComponent(
            getAddressById(components, ZKConfigComponentID)
        ).getValue();
        if (zkConfig.open) {
            uint256[9] memory input = [pickUpInfo.realHash, pickUpInfo.fogHash, pickUpInfo.terrainSeed, pickUpInfo.fogSeed, pickUpInfo.treasureSeed, pickUpInfo.terrainPerlin, pickUpInfo.treasurePerlin, pickUpInfo.width, pickUpInfo.height];
            require(
                ITreasureVerifier(zkConfig.treasureVerifyv2Address).verifyProof(
                    pickUpInfo.a,
                    pickUpInfo.b,
                    pickUpInfo.c,
                    input
                ),
                "Failed pickup proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);

        checkTerrain(pickUpInfo);
        uint256 treasureId = pickUpInfo.fogHash;
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        require(!playerBelonging.has(treasureId), "Already pickedUp");
        // MoveCooldown memory movable = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).getValue(entityId);
        // MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
        // require(
        //     movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
        //     "no action points"
        // );
        setSpaceTimeMark(pickUpInfo.realHash, pickUpInfo.fogSeed);
        (TreasureEffect memory treasureEffect, Treasure memory treasure) = generateTreasure(pickUpInfo);

        playerBelonging.set(treasureId, entityId);
        TreasurePickedComponent(getAddressById(components, TreasurePickedComponentID)).set(
            treasureId
        );
        TreasureEffectv2Component(getAddressById(components, TreasureEffectv2ComponentID)).set(
            treasureId,
            treasureEffect
        );
        Treasurev2Component(getAddressById(components, Treasurev2ComponentID)).set(
            treasureId,
            treasure
        );
        TreasureTimerComponent(getAddressById(components, TreasureTimerComponentID)).set(
            treasureId,
            TreasureTimer({ cooldownTimeout: uint64(0), chargingTimeout: uint64(0)})
        );

        // uint64 remainPoints = movable.remainingMovePoints + (uint64(block.timestamp) - movable.lastMoveTime) / moveConfig.increaseCooldown - 1;
        // if (remainPoints > moveConfig.maxPoints) {
        //     remainPoints = moveConfig.maxPoints;
        // }
        // MoveCooldownComponent(
        //     getAddressById(components, MoveCooldownComponentID)
        // ).set(entityId, MoveCooldown(uint64(block.timestamp), remainPoints));
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

    function checkTerrain(PickUpInfo memory pickUpInfo) internal {
        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            pickUpInfo.width <= mapConfig.gameRadiusX &&
                pickUpInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        if (mapConfig.treasureDifficulty >= mapConfig.resourceDifficulty) {
            require(
                // hash <= treasureDifficulty <= resourceDifficulty || resourceDifficulty < hash <= treasureDifficulty
                (pickUpInfo.terrainPerlin >= 7500 && pickUpInfo.realHash % 2 ** mapConfig.treasureDifficulty == 0),
                "no treasure to pick up"
            );
        } else {
            require(
                (pickUpInfo.terrainPerlin >= 7500 && pickUpInfo.realHash % 2 ** mapConfig.treasureDifficulty == 0 && pickUpInfo.realHash % 2 ** mapConfig.resourceDifficulty > 0),
                "no treasure to pick up"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);
        require(pickUpInfo.fogHash == HiddenPositionComponent(getAddressById(components, HiddenPositionComponentID)).getValue(entityId), "not standing on treasure");
    }

    function generateTreasure(PickUpInfo memory pickUpInfo) internal returns (TreasureEffect memory, Treasure memory) {
        uint256 oriRand = uint256(keccak256(abi.encodePacked(pickUpInfo.treasurePerlin)));
        // uint256 oriRand = pickUpInfo.treasurePerlin;
        (uint64 energy, uint256 effectType, TreasureEffectConfig memory treasureEffectConfig, TreasureEffectGenerateConfig memory treasureEffectGenerateConfig, uint256 rand) = getEffectType(oriRand);
        TreasureEffect memory treasureEffect = TreasureEffect(effectType,
            0,//area
            0);//value
        Treasure memory treasure = Treasure(treasureEffectConfig.effectName,
            treasureEffectConfig.effectAsset,
            treasureEffectConfig.useMode,
            treasureEffectConfig.hitMode,
            treasureEffectGenerateConfig.basicCooldownTime,
            0,//range
            treasureEffectGenerateConfig.basicUsageTimes,
            energy);
        uint256 value = 0;
        (rand, value) = parseRand(rand, uint256(treasureEffectGenerateConfig.minArea), uint256(treasureEffectGenerateConfig.maxArea));
        treasureEffect.area = uint32(value % uint256(2 ** 31));
        uint256 maxValue = uint256(treasureEffectGenerateConfig.maxValue);
        if (treasure.energy > uint64(treasureEffectGenerateConfig.energyPerArea * uint64(treasureEffect.area))) {
            uint64 lastEnergy = treasure.energy - uint64(treasureEffectGenerateConfig.energyPerArea * uint64(treasureEffect.area));
            if (treasureEffectGenerateConfig.energyPerValue > 0 && uint256(lastEnergy / treasureEffectGenerateConfig.energyPerValue) < maxValue) {
                maxValue = uint256(lastEnergy / treasureEffectGenerateConfig.energyPerValue);
            }
        }
        (rand, value) = parseRand(rand, uint256(treasureEffectGenerateConfig.minValue), maxValue);
        treasureEffect.value = uint32(value % uint256(2 ** 31));
        if (treasureEffectGenerateConfig.energyPerRange > 0 && treasure.energy > uint64(treasureEffectGenerateConfig.energyPerArea * uint64(treasureEffect.area)) + uint64(treasureEffectGenerateConfig.energyPerValue * uint64(treasureEffect.value))) {
            uint64 remainEnergy = treasure.energy - uint64(treasureEffectGenerateConfig.energyPerArea * uint64(treasureEffect.area)) - uint64(treasureEffectGenerateConfig.energyPerValue * uint64(treasureEffect.value));
            treasure.range = uint64(uint64(remainEnergy) / uint64(treasureEffectGenerateConfig.energyPerRange));
        } else {
            treasure.range = 1;
        }
        return (treasureEffect, treasure);
    }

    function getEffectType(uint256 rand) internal returns (uint64 energy, uint256 effectType, TreasureEffectConfig memory treasureEffectConfig, TreasureEffectGenerateConfig memory treasureEffectGenerateConfig, uint256 newRand) {
        TreasureEffectGlobalConfig memory treasureEffectGlobalConfig = TreasureEffectGlobalConfigComponent(
            getAddressById(components, TreasureEffectGlobalConfigComponentID)
        ).getValue();
        uint256 value = 0;
        (rand, value) = parseRand(rand, uint256(treasureEffectGlobalConfig.minEnergy), uint256(treasureEffectGlobalConfig.maxEnergy));
        energy = uint64(value % uint256(2 ** 63));
        uint32 effectGroup = 0;
        (rand, effectGroup) = getEffectGroup(treasureEffectGlobalConfig, rand);
        (newRand, effectType, treasureEffectConfig, treasureEffectGenerateConfig) = calculateEffectType(effectGroup, rand);
        return (energy, effectType, treasureEffectConfig, treasureEffectGenerateConfig, newRand);
    }

    function getEffectGroup(TreasureEffectGlobalConfig memory treasureEffectGlobalConfig, uint256 rand) internal returns (uint256 newRand, uint32 effectGroup) {
        uint256 max = 0;
        for (uint256 index = 0; index < treasureEffectGlobalConfig.effectGroupRarely.length; index++) {
            max = max + uint256(treasureEffectGlobalConfig.effectGroupRarely[index]);
        }
        uint256 value = 0;
        (newRand, value) = parseRand(rand, 0, max);
        uint256 lastIndex = 0;
        uint256 count = 0;
        for (uint256 index1 = 0; index1 < treasureEffectGlobalConfig.effectGroupRarely.length; index1++) {
            count = count + uint256(treasureEffectGlobalConfig.effectGroupRarely[index1]);
            lastIndex = index1;
            if (count > value) {
                break;
            }
        }
        effectGroup = treasureEffectGlobalConfig.effectGroups[lastIndex];
        return (newRand, effectGroup);
    }

    function calculateEffectType(uint32 effectGroup, uint256 rand) internal returns (uint256 newRand, uint256 effectType, TreasureEffectConfig memory treasureEffectConfig, TreasureEffectGenerateConfig memory treasureEffectGenerateConfig) {
        TreasureEffectConfigComponent treasureEffectConfigComponent = TreasureEffectConfigComponent(
            getAddressById(components, TreasureEffectConfigComponentID)
        );
        TreasureEffectGenerateConfigComponent treasureEffectGenerateConfigComponent = TreasureEffectGenerateConfigComponent(
            getAddressById(components, TreasureEffectGenerateConfigComponentID)
        );
        TreasureEffectConfigRegisterComponent treasureEffectConfigRegister = TreasureEffectConfigRegisterComponent(
            getAddressById(components, TreasureEffectConfigRegisterComponentID)
        );
        uint256[] memory effectTypes = treasureEffectConfigRegister.getEntitiesWithValue(effectGroup);
        uint256 max = 0;
        for (uint256 index = 0; index < effectTypes.length; index++) {
            TreasureEffectConfig memory treasureEffectConfig1 = treasureEffectConfigComponent.getValue(effectTypes[index]);
            max = max + uint256(treasureEffectConfig1.effectRarely);
        }
        uint256 value = 0;
        (newRand, value) = parseRand(rand, 0, max);
        uint256 count = 0;
        for (uint256 index1 = 0; index1 < effectTypes.length; index1++) {
            TreasureEffectConfig memory treasureEffectConfig1 = treasureEffectConfigComponent.getValue(effectTypes[index1]);
            count = count + uint256(treasureEffectConfig1.effectRarely);
            effectType = effectTypes[index1];
            treasureEffectConfig = treasureEffectConfig1;
            treasureEffectGenerateConfig = treasureEffectGenerateConfigComponent.getValue(effectTypes[index1]);
            if (count > value) {
                break;
            }
        }
        return (newRand, effectType, treasureEffectConfig, treasureEffectGenerateConfig);
    }

    function parseRand(uint256 rand, uint256 min, uint256 max) internal returns (uint256 newRand, uint256 value) {
        // value = 1;
        // newRand = rand;
        if (max > min) {
            value = uint256(rand % uint256(max - min) + uint256(min));
            newRand = rand / uint256(max - min);
        } else {
            value = min;
            newRand = rand;
        }
        return (newRand, value);
    }
}
