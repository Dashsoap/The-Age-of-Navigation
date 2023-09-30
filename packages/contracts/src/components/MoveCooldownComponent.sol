// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.MoveCooldown"));

struct MoveCooldown {
    uint64 lastMoveTime;
    uint64 remainingMovePoints;
}

contract MoveCooldownComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "lastMoveTime";
        values[0] = LibTypes.SchemaValue.UINT64;

        keys[1] = "remainingMovePoints";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(uint256 entity, MoveCooldown memory moveCooldown) public {
        set(
            entity,
            abi.encode(
                moveCooldown.lastMoveTime,
                moveCooldown.remainingMovePoints
            )
        );
    }

    function getValue(
        uint256 entity
    ) public view returns (MoveCooldown memory) {
        (uint64 lastMoveTime, uint64 moveCooldown) = abi.decode(
            getRawValue(entity),
            (uint64, uint64)
        );
        return MoveCooldown(lastMoveTime, moveCooldown);
    }
}
