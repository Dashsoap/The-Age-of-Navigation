// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {TreasureConfigComponent, ID as TreasureConfigComponentID, TreasureConfig, PropertyConfigRange, TreasureTypes} from "components/TreasureConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

library TreasureConfigInitializer {
    function init(IWorld world) internal {
        TreasureConfigComponent treasureConfig = TreasureConfigComponent(
            world.getComponent(TreasureConfigComponentID)
        );
        // ObstructionComponent obstruction = ObstructionComponent(world.getComponent(ObstructionComponentID));
        // EncounterTriggerComponent encounterTrigger = EncounterTriggerComponent(
        //   world.getComponent(EncounterTriggerComponentID)
        // );

        // // Alias these to make it easier to draw the terrain treasure
        // TerrainType O = TerrainType.None;
        // TerrainType T = TerrainType.TallGrass;
        // TerrainType B = TerrainType.Boulder;
        TreasureTypes[7] memory treasureTypes = [
            // [0, 1, 1, 2001, 1001, 3001],
            TreasureTypes({
                typeId: 0,
                isActive: 1,
                isFlight: 1,
                flightEffectId: 2001,
                arrivalEffectId: 1001,
                destroyEffectId: 3001,
                buffEffectId: 0
            }),
            // [1, 1, 1, 2002, 1002, 3002],
            TreasureTypes({
                typeId: 1,
                isActive: 1,
                isFlight: 1,
                flightEffectId: 2002,
                arrivalEffectId: 1002,
                destroyEffectId: 3002,
                buffEffectId: 0
            }),
            // [2, 1, 1, 2003, 1003, 0],
            TreasureTypes({
                typeId: 2,
                isActive: 1,
                isFlight: 1,
                flightEffectId: 2003,
                arrivalEffectId: 1003,
                destroyEffectId: 0,
                buffEffectId: 0
            }),
            // [3, 1, 0, 0, 1501, 0],
            TreasureTypes({
                typeId: 3,
                isActive: 1,
                isFlight: 0,
                flightEffectId: 0,
                arrivalEffectId: 1501,
                destroyEffectId: 0,
                buffEffectId: 0
            }),
            // [4, 1, 0, 0, 1502, 0],
            TreasureTypes({
                typeId: 4,
                isActive: 1,
                isFlight: 0,
                flightEffectId: 0,
                arrivalEffectId: 1502,
                destroyEffectId: 0,
                buffEffectId: 0
            }),
            // [5, 1, 0, 0, 1503, 3003],
            TreasureTypes({
                typeId: 5,
                isActive: 1,
                isFlight: 0,
                flightEffectId: 0,
                arrivalEffectId: 1503,
                destroyEffectId: 3003,
                buffEffectId: 0
            }),
            // [6, 1, 0, 0, 1504, 0]
            TreasureTypes({
                typeId: 6,
                isActive: 1,
                isFlight: 0,
                flightEffectId: 0,
                arrivalEffectId: 1504,
                destroyEffectId: 0,
                buffEffectId: 0
            })
        ];
        // uint32 treasureHeight = uint32(treasureTypes.length);
        // uint32 treasureWidth = uint32(34);
        // bytes memory types = new bytes(treasureHeight * treasureWidth);
        // bytes memory types = abi.encode(treasureTypes);
        TreasureTypes[] memory types = new TreasureTypes[](treasureTypes.length);

        // 将a中的元素复制到types
        for (uint i = 0; i < treasureTypes.length; i++) {
            types[i] = treasureTypes[i];
        }

        // for (uint32 x = 0; x < treasureHeight; x++) {
        //     // bytes8(uint64(treasureTypes[x][0]));
        //     types[x * treasureWidth + 0] = bytes8(uint64(treasureTypes[x][0]))[0];
        //     types[x * treasureWidth + 1] = bytes8(uint64(treasureTypes[x][0]))[1];
        //     types[x * treasureWidth + 2] = bytes8(uint64(treasureTypes[x][0]))[2];
        //     types[x * treasureWidth + 3] = bytes8(uint64(treasureTypes[x][0]))[3];
        //     types[x * treasureWidth + 4] = bytes8(uint64(treasureTypes[x][0]))[4];
        //     types[x * treasureWidth + 5] = bytes8(uint64(treasureTypes[x][0]))[5];
        //     types[x * treasureWidth + 6] = bytes8(uint64(treasureTypes[x][0]))[6];
        //     types[x * treasureWidth + 7] = bytes8(uint64(treasureTypes[x][0]))[7];

        //     types[x * treasureWidth + 8] = bytes1(uint8(treasureTypes[x][1]));
        //     types[x * treasureWidth + 9] = bytes1(uint8(treasureTypes[x][2]));
        //     // bytes8(uint64(treasureTypes[x][3]));
        //     types[x * treasureWidth + 10] = bytes8(uint64(treasureTypes[x][3]))[0];
        //     types[x * treasureWidth + 11] = bytes8(uint64(treasureTypes[x][3]))[1];
        //     types[x * treasureWidth + 12] = bytes8(uint64(treasureTypes[x][3]))[2];
        //     types[x * treasureWidth + 13] = bytes8(uint64(treasureTypes[x][3]))[3];
        //     types[x * treasureWidth + 14] = bytes8(uint64(treasureTypes[x][3]))[4];
        //     types[x * treasureWidth + 15] = bytes8(uint64(treasureTypes[x][3]))[5];
        //     types[x * treasureWidth + 16] = bytes8(uint64(treasureTypes[x][3]))[6];
        //     types[x * treasureWidth + 17] = bytes8(uint64(treasureTypes[x][3]))[7];
        //     // bytes8(uint64(treasureTypes[x][4]));
        //     types[x * treasureWidth + 18] = bytes8(uint64(treasureTypes[x][4]))[0];
        //     types[x * treasureWidth + 19] = bytes8(uint64(treasureTypes[x][4]))[1];
        //     types[x * treasureWidth + 20] = bytes8(uint64(treasureTypes[x][4]))[2];
        //     types[x * treasureWidth + 21] = bytes8(uint64(treasureTypes[x][4]))[3];
        //     types[x * treasureWidth + 22] = bytes8(uint64(treasureTypes[x][4]))[4];
        //     types[x * treasureWidth + 23] = bytes8(uint64(treasureTypes[x][4]))[5];
        //     types[x * treasureWidth + 24] = bytes8(uint64(treasureTypes[x][4]))[6];
        //     types[x * treasureWidth + 25] = bytes8(uint64(treasureTypes[x][4]))[7];
        //     // bytes8(uint64(treasureTypes[x][5]));
        //     types[x * treasureWidth + 26] = bytes8(uint64(treasureTypes[x][5]))[0];
        //     types[x * treasureWidth + 27] = bytes8(uint64(treasureTypes[x][5]))[1];
        //     types[x * treasureWidth + 28] = bytes8(uint64(treasureTypes[x][5]))[2];
        //     types[x * treasureWidth + 29] = bytes8(uint64(treasureTypes[x][5]))[3];
        //     types[x * treasureWidth + 30] = bytes8(uint64(treasureTypes[x][5]))[4];
        //     types[x * treasureWidth + 31] = bytes8(uint64(treasureTypes[x][5]))[5];
        //     types[x * treasureWidth + 32] = bytes8(uint64(treasureTypes[x][5]))[6];
        //     types[x * treasureWidth + 33] = bytes8(uint64(treasureTypes[x][5]))[7];
        // }

        PropertyConfigRange[13] memory treasureProperties = [
            PropertyConfigRange({
                propertyId: 1001,
                triggerType: 1,
                effectType: 1,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 10,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 30,
                energyPerShield: 0
            }),
            // [1002, 1, 0, 10, 20, 1, 2, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 1002,
                triggerType: 1,
                effectType: 0,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 2,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [1003, 1, 3, 10, 20, 1, 35, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 1003,
                triggerType: 1,
                effectType: 3,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 35,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [1501, 0, 4, 10, 20, 1, 50, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 1501,
                triggerType: 0,
                effectType: 4,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 50,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [1502, 0, 5, 10, 20, 1, 2, 20, 1, 30, 0],
            PropertyConfigRange({
                propertyId: 1502,
                triggerType: 0,
                effectType: 5,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 2,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 30,
                energyPerShield: 0
            }),
            // [1503, 0, 6, 10, 20, 1, 3, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 1503,
                triggerType: 0,
                effectType: 6,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 3,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [1504, 0, 7, 10, 20, 1, 5, 20, 1, 30, 0],
            PropertyConfigRange({
                propertyId: 1504,
                triggerType: 0,
                effectType: 7,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 5,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 30,
                energyPerShield: 0
            }),
            // [2001, 2, 1, 10, 20, 1, 10, 20, 1, 30, 0],
            PropertyConfigRange({
                propertyId: 2001,
                triggerType: 2,
                effectType: 1,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 10,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 30,
                energyPerShield: 0
            }),
            // [2002, 2, 0, 10, 20, 1, 2, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 2002,
                triggerType: 2,
                effectType: 0,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 2,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [2003, 2, 8, 10, 20, 1, 5, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 2003,
                triggerType: 2,
                effectType: 8,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 5,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [3001, 3, 1, 10, 20, 1, 10, 20, 1, 30, 0],
            PropertyConfigRange({
                propertyId: 3001,
                triggerType: 3,
                effectType: 1,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 10,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 30,
                energyPerShield: 0
            }),
            // [3002, 3, 0, 10, 20, 1, 2, 20, 1, 0, 0],
            PropertyConfigRange({
                propertyId: 3002,
                triggerType: 3,
                effectType: 0,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 2,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            }),
            // [3003, 3, 9, 10, 20, 1, 2, 20, 1, 0, 0]
            PropertyConfigRange({
                propertyId: 3003,
                triggerType: 3,
                effectType: 9,
                energyPerRange: 10,
                rangeMax: 20,
                rangeMin: 1,
                energyPerArea: 2,
                areaMax: 20,
                areaMin: 1,
                energyPerDamage: 0,
                energyPerShield: 0
            })
        ];

        PropertyConfigRange[] memory properties = new PropertyConfigRange[](treasureProperties.length);

        // 获取a的长度并设置properties的长度
        // properties.length = treasureProperties.length;

        // 将a中的元素复制到properties
        for (uint j = 0; j < treasureProperties.length; j++) {
            properties[j] = treasureProperties[j];
        }

        // uint32 height = uint32(treasureProperties.length);
        // uint32 width = uint32(42);
        // bytes memory properties = new bytes(width * height);
        // bytes memory properties = abi.encode(treasureProperties);

        // for (uint32 y = 0; y < height; y++) {
        //     // bytes8(uint64(treasureProperties[y][0]));
        //     types[y * treasureWidth + 0] = bytes8(uint64(treasureProperties[y][0]))[0];
        //     types[y * treasureWidth + 1] = bytes8(uint64(treasureProperties[y][0]))[1];
        //     types[y * treasureWidth + 2] = bytes8(uint64(treasureProperties[y][0]))[2];
        //     types[y * treasureWidth + 3] = bytes8(uint64(treasureProperties[y][0]))[3];
        //     types[y * treasureWidth + 4] = bytes8(uint64(treasureProperties[y][0]))[4];
        //     types[y * treasureWidth + 5] = bytes8(uint64(treasureProperties[y][0]))[5];
        //     types[y * treasureWidth + 6] = bytes8(uint64(treasureProperties[y][0]))[6];
        //     types[y * treasureWidth + 7] = bytes8(uint64(treasureProperties[y][0]))[7];
        //     types[y * treasureWidth + 8] = bytes1(uint8(treasureTypes[y][1]));
        //     types[y * treasureWidth + 9] = bytes1(uint8(treasureTypes[y][2]));
        //     // bytes4(uint32(treasureProperties[y][3]));
        //     types[y * treasureWidth + 10] = bytes4(uint32(treasureProperties[y][3]))[0];
        //     types[y * treasureWidth + 11] = bytes4(uint32(treasureProperties[y][3]))[1];
        //     types[y * treasureWidth + 12] = bytes4(uint32(treasureProperties[y][3]))[2];
        //     types[y * treasureWidth + 13] = bytes4(uint32(treasureProperties[y][3]))[3];
        //     // bytes4(uint32(treasureProperties[y][4])),
        //     types[y * treasureWidth + 14] = bytes4(uint32(treasureProperties[y][4]))[0];
        //     types[y * treasureWidth + 15] = bytes4(uint32(treasureProperties[y][4]))[1];
        //     types[y * treasureWidth + 16] = bytes4(uint32(treasureProperties[y][4]))[2];
        //     types[y * treasureWidth + 17] = bytes4(uint32(treasureProperties[y][4]))[3];
        //     // bytes4(uint32(treasureProperties[y][5])),
        //     types[y * treasureWidth + 18] = bytes4(uint32(treasureProperties[y][5]))[0];
        //     types[y * treasureWidth + 19] = bytes4(uint32(treasureProperties[y][5]))[1];
        //     types[y * treasureWidth + 20] = bytes4(uint32(treasureProperties[y][5]))[2];
        //     types[y * treasureWidth + 21] = bytes4(uint32(treasureProperties[y][5]))[3];
        //     // bytes4(uint32(treasureProperties[y][6])),
        //     types[y * treasureWidth + 22] = bytes4(uint32(treasureProperties[y][6]))[0];
        //     types[y * treasureWidth + 23] = bytes4(uint32(treasureProperties[y][6]))[1];
        //     types[y * treasureWidth + 24] = bytes4(uint32(treasureProperties[y][6]))[2];
        //     types[y * treasureWidth + 25] = bytes4(uint32(treasureProperties[y][6]))[3];
        //     // bytes4(uint32(treasureProperties[y][7])),
        //     types[y * treasureWidth + 26] = bytes4(uint32(treasureProperties[y][7]))[0];
        //     types[y * treasureWidth + 27] = bytes4(uint32(treasureProperties[y][7]))[1];
        //     types[y * treasureWidth + 28] = bytes4(uint32(treasureProperties[y][7]))[2];
        //     types[y * treasureWidth + 29] = bytes4(uint32(treasureProperties[y][7]))[3];
        //     // bytes4(uint32(treasureProperties[y][8])),
        //     types[y * treasureWidth + 30] = bytes4(uint32(treasureProperties[y][8]))[0];
        //     types[y * treasureWidth + 31] = bytes4(uint32(treasureProperties[y][8]))[1];
        //     types[y * treasureWidth + 32] = bytes4(uint32(treasureProperties[y][8]))[2];
        //     types[y * treasureWidth + 33] = bytes4(uint32(treasureProperties[y][8]))[3];
        //     // bytes4(uint32(treasureProperties[y][9])),
        //     types[y * treasureWidth + 34] = bytes4(uint32(treasureProperties[y][9]))[0];
        //     types[y * treasureWidth + 35] = bytes4(uint32(treasureProperties[y][9]))[1];
        //     types[y * treasureWidth + 36] = bytes4(uint32(treasureProperties[y][9]))[2];
        //     types[y * treasureWidth + 37] = bytes4(uint32(treasureProperties[y][9]))[3];
        //     // bytes4(uint32(treasureProperties[y][10]))
        //     types[y * treasureWidth + 38] = bytes4(uint32(treasureProperties[y][10]))[0];
        //     types[y * treasureWidth + 39] = bytes4(uint32(treasureProperties[y][10]))[1];
        //     types[y * treasureWidth + 40] = bytes4(uint32(treasureProperties[y][10]))[2];
        //     types[y * treasureWidth + 41] = bytes4(uint32(treasureProperties[y][10]))[3];
        // }

        treasureConfig.set(TreasureConfig({ energyMax: 200, energyMin: 50, treasureTypes: types, properties: properties }));
    }
}
