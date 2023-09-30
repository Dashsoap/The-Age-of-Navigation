// SPDX-License-Identifier: MIT
// components: ["TreasureComponent", "PlayerBelongingComponent", "TreasureEffectComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureConfigComponent, ID as TreasureConfigComponentID, TreasureConfig, PropertyConfigRange, TreasureTypes} from "components/TreasureConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

// import {ResourcePositionComponent, ID as ResourcePositionComponentID} from "components/ResourcePositionComponent.sol";
import {PlayerBelongingComponent, ID as PlayerBelongingComponentID} from "components/PlayerBelongingComponent.sol";
import {TreasureComponent, ID as TreasureComponentID, Treasure} from "components/TreasureComponent.sol";
import {TreasureEffectComponent, ID as TreasureEffectComponentID, TreasureEffect, Effect} from "components/TreasureEffectComponent.sol";
// import {PlayerComponent, ID as PlayerComponentID} from "components/PlayerComponent.sol";
// import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
// import {WarshipComponent, ID as WarshipComponentID, Warship} from "components/WarshipComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {ITreasureVerifier} from "verifiers/TreasureVerifier.sol";

uint256 constant ID = uint256(keccak256("system.PickUpTreasure"));

struct PickUpInfo {
    uint256 coordHash;
    uint256 width;
    uint256 height;
    uint256 seed;
    uint256 treasureSeed;
    uint256 terrainPerlin;
    uint256 treasurePerlin;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
    string treasureType;
    uint64 typeId;
    uint256 energy;
}

contract PickUpTreasureSystem is System {
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
            uint256[7] memory input = [pickUpInfo.coordHash, pickUpInfo.seed, pickUpInfo.treasureSeed, pickUpInfo.terrainPerlin, pickUpInfo.treasurePerlin, pickUpInfo.width, pickUpInfo.height];
            require(
                ITreasureVerifier(zkConfig.treasureVerifyAddress).verifyProof(
                    pickUpInfo.a,
                    pickUpInfo.b,
                    pickUpInfo.c,
                    input
                ),
                "Failed pickup proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);

        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            pickUpInfo.width <= mapConfig.gameRadiusX &&
                pickUpInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        require(
            // hash <= treasureDifficulty <= resourceDifficulty || resourceDifficulty < hash <= treasureDifficulty
            (pickUpInfo.terrainPerlin >= 7500 && pickUpInfo.coordHash / 16 ** (64 - mapConfig.treasureDifficulty) == 0),
            "no treasure to pick up"
        );
        // ResourcePositionComponent resourcePosition = ResourcePositionComponent(
        //     getAddressById(components, ResourcePositionComponentID)
        // );
        // uint256[] memory treasureIds =  resourcePosition.getEntitiesWithValue(pickUpInfo.coordHash);
        uint256 treasureId = pickUpInfo.coordHash;
        // if (treasureIds.length > 0) {
        //     treasureId = treasureIds[0];
        // }
        // if (treasureId == 0) {
        //     treasureId = world.getUniqueEntityId();
        // }
        PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
            getAddressById(components, PlayerBelongingComponentID)
        );
        require(!playerBelonging.has(treasureId), "Already pickedUp");
        TreasureConfig memory treasureConfig = TreasureConfigComponent(
            getAddressById(components, TreasureConfigComponentID)
        ).getValue();
        require(pickUpInfo.energy >= treasureConfig.energyMin && pickUpInfo.energy <= treasureConfig.energyMax, "energy over limit");

        // generate treasure properties
        // resourcePosition.set(treasureId, pickUpInfo.coordHash);

        TreasureComponent(getAddressById(components, TreasureComponentID)).set(
            entityId,
            Treasure(pickUpInfo.energy, pickUpInfo.treasureType)
        );
        // MoveCooldownComponent(
        //     getAddressById(components, MoveCooldownComponentID)
        // ).set(entityId, MoveCooldown(uint64(block.timestamp), treasureConfig.initPoints));
    }

    function generateProperties(PickUpInfo memory pickUpInfo) internal {
        TreasureConfig memory treasureConfig = TreasureConfigComponent(
            getAddressById(components, TreasureConfigComponentID)
        ).getValue();
        TreasureTypes memory treasureTypes = TreasureTypes(0, 0, 0, 0, 0, 0, 0);
        for (uint i = 0; i < treasureConfig.treasureTypes.length; i++) {
            if (treasureConfig.treasureTypes[i].typeId == pickUpInfo.typeId) {
                treasureTypes = treasureConfig.treasureTypes[i];
                break;
            }
        }
        require(treasureTypes.typeId > 0, "type Id invalid");
        PropertyConfigRange memory flightConfig = PropertyConfigRange(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        PropertyConfigRange memory arrivalConfig = PropertyConfigRange(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        PropertyConfigRange memory destroyConfig = PropertyConfigRange(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        PropertyConfigRange memory buffConfig = PropertyConfigRange(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0);
        for (uint i = 0; i < treasureConfig.properties.length; i++) {
            if (treasureConfig.properties[i].propertyId == treasureTypes.flightEffectId) {
                flightConfig = treasureConfig.properties[i];
            }
            if (treasureConfig.properties[i].propertyId == treasureTypes.arrivalEffectId) {
                arrivalConfig = treasureConfig.properties[i];
            }
            if (treasureConfig.properties[i].propertyId == treasureTypes.destroyEffectId) {
                destroyConfig = treasureConfig.properties[i];
            }
            if (treasureConfig.properties[i].propertyId == treasureTypes.buffEffectId) {
                buffConfig = treasureConfig.properties[i];
            }
            if (flightConfig.propertyId != 0 && arrivalConfig.propertyId != 0 && destroyConfig.propertyId != 0 && buffConfig.propertyId != 0) {
                break;
            }
        }
        require(flightConfig.propertyId != 0 || arrivalConfig.propertyId != 0 || destroyConfig.propertyId != 0 || buffConfig.propertyId != 0, "treasure type invalid");
        uint256 rand = uint(keccak256(abi.encodePacked(block.number, msg.sender, pickUpInfo.coordHash, pickUpInfo.treasureSeed, pickUpInfo.treasureType, pickUpInfo.energy, block.difficulty)));
        TreasureEffect memory treasureEffect = TreasureEffect({isActive: treasureTypes.isActive,
         isFlight: treasureTypes.isFlight,
         flight: Effect({valid: 0, triggerType: 0, effectType: 0, energy: 0, range: 0, area: 0, damage: 0, shield: 0}),
         arrival: Effect({valid: 0, triggerType: 0, effectType: 0, energy: 0, range: 0, area: 0, damage: 0, shield: 0}),
         destroy: Effect({valid: 0, triggerType: 0, effectType: 0, energy: 0, range: 0, area: 0, damage: 0, shield: 0}),
         buff: Effect({valid: 0, triggerType: 0, effectType: 0, energy: 0, range: 0, area: 0, damage: 0, shield: 0})});
        uint256 lastEnergy = pickUpInfo.energy;
        if (flightConfig.propertyId > 0) {
            (treasureEffect.flight, rand) = propertyConfigToEffect(flightConfig, rand, lastEnergy);
            require(lastEnergy >= treasureEffect.flight.energy, "lack of energy");
            lastEnergy = lastEnergy - treasureEffect.flight.energy;
        }
        if (arrivalConfig.propertyId > 0) {
            (treasureEffect.arrival, rand) = propertyConfigToEffect(arrivalConfig, rand, lastEnergy);
            require(lastEnergy >= treasureEffect.arrival.energy, "lack of energy");
            lastEnergy = lastEnergy - treasureEffect.arrival.energy;
        }
        if (destroyConfig.propertyId > 0) {
            (treasureEffect.destroy, rand) = propertyConfigToEffect(destroyConfig, rand, lastEnergy);
            require(lastEnergy >= treasureEffect.destroy.energy, "lack of energy");
            lastEnergy = lastEnergy - treasureEffect.destroy.energy;
        }
        if (buffConfig.propertyId > 0) {
            (treasureEffect.buff, rand) = propertyConfigToEffect(buffConfig, rand, lastEnergy);
            require(lastEnergy >= treasureEffect.buff.energy, "lack of energy");
            lastEnergy = lastEnergy - treasureEffect.buff.energy;
        }
        TreasureEffectComponent(getAddressById(components, TreasureEffectComponentID)).set(
            addressToEntity(msg.sender),
            treasureEffect
        );
    }

    function propertyConfigToEffect(PropertyConfigRange memory propertyConfigRange, uint256 rand, uint256 lastEnergy) internal returns (Effect memory effect, uint256 newRand) {
        newRand = rand;
        if (propertyConfigRange.propertyId > 0 && lastEnergy >= 50) {
            effect.valid = 1;
            effect.triggerType = propertyConfigRange.triggerType;
            effect.effectType = propertyConfigRange.effectType;
            // effect.energy = propertyConfigRange.effectType;
            (newRand, effect.range) = getRandom(newRand, propertyConfigRange.rangeMin, propertyConfigRange.rangeMax);
            (newRand, effect.area) = getRandom(newRand, propertyConfigRange.areaMin, propertyConfigRange.areaMax);
            // effect.area = propertyConfigRange.effectType;
            if (propertyConfigRange.energyPerDamage > 0) {
                effect.damage = 1;
            }
            if (propertyConfigRange.energyPerShield > 0) {
                effect.shield = 1;
            }
            effect.energy = propertyConfigRange.energyPerArea * effect.area + propertyConfigRange.energyPerDamage * effect.damage + propertyConfigRange.energyPerRange * effect.range + propertyConfigRange.energyPerShield * effect.shield;
        }
        return (effect, newRand);
    }

    function getRandom(uint256 rand, uint32 min, uint32 max) internal returns (uint256 newRand, uint32 value) {
        if (max - min > 0) {
            value = uint32(rand % uint256(max - min) + uint256(min));
            newRand = rand / uint256(max - min);
        } else {
            value = 0;
            newRand = rand;
        }
        return (newRand, value);
    }
}
