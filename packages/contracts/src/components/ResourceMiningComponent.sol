// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.ResourceMining"));

struct ResourceMining {
    uint256 remain;
    uint256 cache;
}

contract ResourceMiningComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "remain";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "cache";
        values[1] = LibTypes.SchemaValue.UINT256;
    }

    function set(
        uint256 entity,
        ResourceMining memory resourceMining
    ) public {
        set(entity, abi.encode(resourceMining.remain, resourceMining.cache));
    }

    function getValue(
        uint256 entity
    ) public view returns (ResourceMining memory) {
        (uint256 remain, uint256 cache) = abi.decode(
            getRawValue(entity),
            (uint256, uint256)
        );
        return ResourceMining(remain, cache);
    }
}
