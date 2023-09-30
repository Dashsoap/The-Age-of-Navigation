// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureBounded"));

struct TreasureBounded {
    uint64 boundTime;
    uint64 timeout;
}

contract TreasureBoundedComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "boundTime";
        values[0] = LibTypes.SchemaValue.UINT64;

        keys[1] = "timeout";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        TreasureBounded memory treasureBounded
    ) public {
        set(entity, abi.encode(treasureBounded.boundTime, treasureBounded.timeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureBounded memory) {
        (uint64 boundTime, uint64 timeout) = abi.decode(
            getRawValue(entity),
            (uint64, uint64)
        );
        return TreasureBounded(boundTime, timeout);
    }
}
