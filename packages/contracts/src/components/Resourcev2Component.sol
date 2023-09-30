// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Resourcev2"));

struct Resource {
    uint256 value;
    uint256 difficulty;
    uint64 recuitSeconds;
}

contract Resourcev2Component is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "difficulty";
        values[1] = LibTypes.SchemaValue.UINT256;

        keys[2] = "recuitSeconds";
        values[2] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        Resource memory resource
    ) public {
        set(entity, abi.encode(resource.value, resource.difficulty, resource.recuitSeconds));
    }

    function getValue(
        uint256 entity
    ) public view returns (Resource memory) {
        (uint256 value, uint256 difficulty, uint64 recuitSeconds) = abi.decode(
            getRawValue(entity),
            (uint256, uint256, uint64)
        );
        return Resource(value, difficulty, recuitSeconds);
    }
}
