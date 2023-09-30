// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";
import {TechComponent} from "components/TechComponent.sol";

uint256 constant ID = uint256(keccak256("component.TechUpdating"));

struct TechUpdating {
    uint256 techGroupId;
    uint64 nextLevel;
    uint64 finishTime;
}

contract TechUpdatingComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "techGroupId";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "nextLevel";
        values[1] = LibTypes.SchemaValue.UINT64;

        keys[2] = "finishTime";
        values[2] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        TechUpdating memory techUpdating
    ) public {
        set(entity, abi.encode(techUpdating.techGroupId, techUpdating.nextLevel, techUpdating.finishTime));
    }

    function getValue(
        uint256 entity
    ) public view returns (TechUpdating memory) {
        (uint256 techGroupId, uint64 nextLevel, uint64 finishTime) = abi.decode(
            getRawValue(entity),
            (uint256, uint64, uint64)
        );
        return TechUpdating(techGroupId, nextLevel, finishTime);
    }
}
