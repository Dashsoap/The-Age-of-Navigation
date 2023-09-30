// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Charging"));

struct Charging {
    uint256 chargingEntity;
    uint64 chargingTimeout;
}

contract ChargingComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "chargingEntity";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "chargingTimeout";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        Charging memory charging
    ) public {
        set(entity, abi.encode(charging.chargingEntity, charging.chargingTimeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (Charging memory) {
        (uint256 chargingEntity, uint64 chargingTimeout) = abi.decode(
            getRawValue(entity),
            (uint256, uint64)
        );
        return Charging(chargingEntity, chargingTimeout);
    }
}
