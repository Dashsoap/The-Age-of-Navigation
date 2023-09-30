// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.TechConfigGlobal"));

struct TechConfigGlobal {
    uint32 maxQueueLength;
}

contract TechConfigGlobalComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](1);
        values = new LibTypes.SchemaValue[](1);

        keys[0] = "maxQueueLength";
        values[0] = LibTypes.SchemaValue.UINT32;
    }

    function set(
        TechConfigGlobal memory techConfigGlobal
    ) public {
        set(SingletonID, abi.encode(techConfigGlobal.maxQueueLength));
    }

    function getValue() public view returns (TechConfigGlobal memory) {
        (uint32 maxQueueLength) = abi.decode(
            getRawValue(SingletonID),
            (uint32)
        );
        return TechConfigGlobal(maxQueueLength);
    }
}