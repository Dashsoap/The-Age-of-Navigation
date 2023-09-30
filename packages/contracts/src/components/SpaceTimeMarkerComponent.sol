// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.SpaceTimeMarker"));

struct SpaceTimeMarker {
    uint32 seed;
    uint64 timeout;
    bool isUnlimited;
}

contract SpaceTimeMarkerComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "seed";
        values[0] = LibTypes.SchemaValue.UINT32;

        keys[1] = "timeout";
        values[1] = LibTypes.SchemaValue.UINT64;

        keys[2] = "isUnlimited";
        values[2] = LibTypes.SchemaValue.BOOL;
    }

    function set(
        uint256 entity,
        SpaceTimeMarker memory spaceTimeMarker
    ) public {
        set(entity, abi.encode(spaceTimeMarker.seed, spaceTimeMarker.timeout, spaceTimeMarker.isUnlimited));
    }

    function getValue(
        uint256 entity
    ) public view returns (SpaceTimeMarker memory) {
        (uint32 seed, uint64 timeout, bool isUnlimited) = abi.decode(
            getRawValue(entity),
            (uint32, uint64, bool)
        );
        return SpaceTimeMarker(seed, timeout, isUnlimited);
    }
}
