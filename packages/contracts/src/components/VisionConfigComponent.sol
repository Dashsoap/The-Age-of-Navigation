// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";
import {SingletonID} from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.VisionConfig"));

struct VisionConfig {
    uint64 remainTime;
    uint64 maxDistance;
}

contract VisionConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "remainTime";
        values[0] = LibTypes.SchemaValue.UINT64;

        keys[1] = "maxDistance";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(VisionConfig memory visionConfig) public {
        set(
            SingletonID,
            abi.encode(visionConfig.remainTime, visionConfig.maxDistance)
        );
    }

    function getValue() public view returns (VisionConfig memory) {
        (uint64 remainTime, uint64 maxDistance) = abi.decode(
            getRawValue(SingletonID),
            (uint64, uint64)
        );
        return VisionConfig(remainTime, maxDistance);
    }
}
