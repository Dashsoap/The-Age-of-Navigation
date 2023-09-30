// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.ResourceBuilding"));

struct ResourceBuilding {
    uint32 value;
    uint64 timeout;
}

contract ResourceBuildingComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.UINT32;

        keys[1] = "timeout";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        ResourceBuilding memory resourceBuilding
    ) public {
        set(entity, abi.encode(resourceBuilding.value, resourceBuilding.timeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (ResourceBuilding memory) {
        (uint32 value, uint64 timeout) = abi.decode(
            getRawValue(entity),
            (uint32, uint64)
        );
        return ResourceBuilding(value, timeout);
    }
}
