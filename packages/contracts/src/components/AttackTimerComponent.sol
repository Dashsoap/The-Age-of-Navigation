// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.AttackTimer"));

struct AttackTimer {
    uint64 cooldownTimeout;
    uint64 chargingTimeout;
}

contract AttackTimerComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "cooldownTimeout";
        values[0] = LibTypes.SchemaValue.UINT64;

        keys[1] = "chargingTimeout";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        AttackTimer memory attackTimer
    ) public {
        set(entity, abi.encode(attackTimer.cooldownTimeout, attackTimer.chargingTimeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (AttackTimer memory) {
        (uint64 cooldownTimeout, uint64 chargingTimeout) = abi.decode(
            getRawValue(entity),
            (uint64, uint64)
        );
        return AttackTimer(cooldownTimeout, chargingTimeout);
    }
}
