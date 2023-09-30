// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";
import {Component} from "solecs/Component.sol";

uint256 constant ID = uint256(keccak256("component.Tech"));

struct Tech {
    uint64 level;
    uint64 updateTime;
    uint256 techGroupId;
}

contract TechComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "level";
        values[0] = LibTypes.SchemaValue.UINT64;

        keys[1] = "updateTime";
        values[1] = LibTypes.SchemaValue.UINT64;

        keys[2] = "techGroupId";
        values[2] = LibTypes.SchemaValue.UINT256;
    }

    function set(
        uint256 entity,
        Tech memory tech
    ) public {
        set(entity, abi.encode(tech.level, tech.updateTime, tech.techGroupId));
    }

    function getValue(
        uint256 entity
    ) public view returns (Tech memory) {
        (uint64 level, uint64 updateTime, uint256 techGroupId) = abi.decode(
            getRawValue(entity),
            (uint64, uint64, uint256)
        );
        return Tech(level, updateTime, techGroupId);
    }
}