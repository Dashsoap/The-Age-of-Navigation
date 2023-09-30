// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureEffectGenerateConfig"));

struct TreasureEffectGenerateConfig {
    uint64 energyPerArea;
    uint64 energyPerValue;
    uint64 basicCooldownTime;
    uint64 energyPerRange;
    uint32 basicUsageTimes;
    uint64 minArea;
    uint64 maxArea;
    uint64 minValue;
    uint64 maxValue;
}

contract TreasureEffectGenerateConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](9);
        values = new LibTypes.SchemaValue[](9);

        keys[0] = "energyPerArea";
        values[0] = LibTypes.SchemaValue.UINT64;

        keys[1] = "energyPerValue";
        values[1] = LibTypes.SchemaValue.UINT64;

        keys[2] = "basicCooldownTime";
        values[2] = LibTypes.SchemaValue.UINT64;

        keys[3] = "energyPerRange";
        values[3] = LibTypes.SchemaValue.UINT64;

        keys[4] = "basicUsageTimes";
        values[4] = LibTypes.SchemaValue.UINT32;

        keys[5] = "minArea";
        values[5] = LibTypes.SchemaValue.UINT64;

        keys[6] = "maxArea";
        values[6] = LibTypes.SchemaValue.UINT64;

        keys[7] = "minValue";
        values[7] = LibTypes.SchemaValue.UINT64;

        keys[8] = "maxValue";
        values[8] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        TreasureEffectGenerateConfig memory treasureEffect
    ) public {
        set(entity, abi.encode(treasureEffect.energyPerArea,
            treasureEffect.energyPerValue,
            treasureEffect.basicCooldownTime,
            treasureEffect.energyPerRange,
            treasureEffect.basicUsageTimes,
            treasureEffect.minArea,
            treasureEffect.maxArea,
            treasureEffect.minValue,
            treasureEffect.maxValue));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureEffectGenerateConfig memory) {
        (uint64 energyPerArea,
            uint64 energyPerValue,
            uint64 basicCooldownTime,
            uint64 energyPerRange,
            uint32 basicUsageTimes,
            uint64 minArea,
            uint64 maxArea,
            uint64 minValue,
            uint64 maxValue) = abi.decode(
            getRawValue(entity),
            (uint64, uint64, uint64, uint64, uint32, uint64, uint64, uint64, uint64)
        );
        return TreasureEffectGenerateConfig(energyPerArea, energyPerValue, basicCooldownTime, energyPerRange, basicUsageTimes, minArea, maxArea, minValue, maxValue);
    }
}
