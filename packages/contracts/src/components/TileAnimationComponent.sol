// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TileAnimation"));

struct TileAnimation {
    string animation;
    uint64 timeout;
}

contract TileAnimationComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "animation";
        values[0] = LibTypes.SchemaValue.STRING;

        keys[1] = "timeout";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        TileAnimation memory drawTile
    ) public {
        set(entity, abi.encode(drawTile.animation, drawTile.timeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (TileAnimation memory) {
        (string memory animation, uint64 timeout) = abi.decode(
            getRawValue(entity),
            (string, uint64)
        );
        return TileAnimation(animation, timeout);
    }
}
