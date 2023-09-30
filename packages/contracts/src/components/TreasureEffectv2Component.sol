// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureEffectv2"));

struct TreasureEffect {
    uint256 effectType;
    uint32 area;
    uint32 value;
}

contract TreasureEffectv2Component is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "effectType";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "area";
        values[1] = LibTypes.SchemaValue.UINT32;
        
        keys[2] = "value";
        values[2] = LibTypes.SchemaValue.UINT32;
    }

    function set(
        uint256 entity,
        TreasureEffect memory treasureEffect
    ) public {
        set(entity, abi.encode(treasureEffect.effectType, treasureEffect.area, treasureEffect.value));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureEffect memory) {
        (uint256 effectType, uint32 area, uint32 value) = abi.decode(
            getRawValue(entity),
            (uint256, uint32, uint32)
        );
        return TreasureEffect(effectType, area, value);
    }
}
