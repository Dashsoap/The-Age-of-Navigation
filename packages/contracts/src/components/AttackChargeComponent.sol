// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.AttackCharge"));

struct AttackCharge {
    uint256 coord_hash;
    uint256 direction;
}

contract AttackChargeComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "coord_hash";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "direction";
        values[1] = LibTypes.SchemaValue.UINT256;
    }

    function set(
        uint256 entity,
        AttackCharge memory attackCharge
    ) public {
        set(entity, abi.encode(attackCharge.coord_hash, attackCharge.direction));
    }

    function getValue(
        uint256 entity
    ) public view returns (AttackCharge memory) {
        (uint256 coord_hash, uint256 direction) = abi.decode(
            getRawValue(entity),
            (uint256, uint256)
        );
        return AttackCharge(coord_hash, direction);
    }
}
