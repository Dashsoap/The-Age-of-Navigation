// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Shield"));

struct Shield {
    uint32 shieldValue;
    uint32 shieldArea;
    uint64 shieldTimeout;
}

contract ShieldComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](3);
        values = new LibTypes.SchemaValue[](3);

        keys[0] = "shieldValue";
        values[0] = LibTypes.SchemaValue.UINT32;

        keys[1] = "shieldArea";
        values[1] = LibTypes.SchemaValue.UINT32;

        keys[2] = "shieldTimeout";
        values[2] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        Shield memory shield
    ) public {
        set(entity, abi.encode(shield.shieldValue, shield.shieldArea, shield.shieldTimeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (Shield memory) {
        (uint32 shieldValue, uint32 shieldArea, uint64 shieldTimeout) = abi.decode(
            getRawValue(entity),
            (uint32, uint32, uint64)
        );
        return Shield(shieldValue, shieldArea, shieldTimeout);
    }
}
