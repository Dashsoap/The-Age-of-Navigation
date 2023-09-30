// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TechEffect"));

struct TechEffect {
    uint256 techEffectId;
    uint256 techEffectLevel;
    uint64 techEffectType;
    uint64 buffValue;
    string source;
}

contract TechEffectComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](5);
        values = new LibTypes.SchemaValue[](5);

        keys[0] = "techEffectId";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "techEffectLevel";
        values[1] = LibTypes.SchemaValue.UINT256;

        keys[2] = "techEffectType";
        values[2] = LibTypes.SchemaValue.UINT64;

        keys[3] = "buffValue";
        values[3] = LibTypes.SchemaValue.UINT64;

        keys[4] = "source";
        values[4] = LibTypes.SchemaValue.STRING; 
    }

    function set(
        uint256 entity,
        TechEffect memory techEffect
    ) public {
        set(entity, abi.encode(techEffect.techEffectId, techEffect.techEffectLevel, techEffect.techEffectType, techEffect.buffValue, techEffect.source));
    }

    function getValue(
        uint256 entity
    ) public view returns (TechEffect memory) {
        (uint256 techEffectId, uint256 techEffectLevel, uint64 techEffectType, uint64 buffValue, string memory source) = abi.decode(
            getRawValue(entity),
            (uint256, uint256, uint64, uint64, string)
        );
        return TechEffect(techEffectId, techEffectLevel, techEffectType, buffValue, source);
    }
}