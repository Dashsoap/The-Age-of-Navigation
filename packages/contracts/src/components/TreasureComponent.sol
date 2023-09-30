// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Treasure"));

struct Treasure {
    uint256 energy;
    string baseType;
}

contract TreasureComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "energy";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "baseType";
        values[1] = LibTypes.SchemaValue.STRING;
    }

    function set(
        uint256 entity,
        Treasure memory treasure
    ) public {
        set(entity, abi.encode(treasure.energy, treasure.baseType));
    }

    function getValue(
        uint256 entity
    ) public view returns (Treasure memory) {
        (uint256 energy, string memory baseType) = abi.decode(
            getRawValue(entity),
            (uint256, string)
        );
        return Treasure(energy, baseType);
    }
}