// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TechEffectConfig"));

struct TechEffectConfig {
    uint32 techEffectType;
    string asset;
    string name;
    uint64 buffRareType;
}

contract TechEffectConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](4);
        values = new LibTypes.SchemaValue[](4);

        keys[0] = "techEffectType";
        values[0] = LibTypes.SchemaValue.UINT32;

        keys[1] = "asset";
        values[1] = LibTypes.SchemaValue.STRING;

        keys[2] = "name";
        values[2] = LibTypes.SchemaValue.STRING;

        keys[3] = "buffRareType";
        values[3] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        TechEffectConfig memory techEffect
    ) public {
        set(entity, abi.encode(techEffect.techEffectType, 
        techEffect.asset, 
        techEffect.name, 
        techEffect.buffRareType));
    }

    function getValue(
        uint256 entity
    ) public view returns (TechEffectConfig memory) {
        (
            uint32 techEffectType, 
            string memory asset, 
            string memory name, 
            uint64 buffRareType
        ) = abi.decode(
            getRawValue(entity),
            (uint32, string, string, uint64)
        );
        return TechEffectConfig(techEffectType, asset, name, buffRareType);
    }
}
