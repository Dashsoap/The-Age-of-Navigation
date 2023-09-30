// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";
import {SingletonID} from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.ZKConfig"));

struct ZKConfig {
    bool open;
    address initVerifyAddress;
    address moveVerifyAddress;
    address markVerifyAddress;
    address treasureVerifyAddress;
    address treasureVerifyv2Address;
    address resourceVerifyAddress;
    address resourceVerifyv2Address;
    address attackPathVerifyAddress;
    address coordVerifyAddress;
}

contract ZKConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](10);
        values = new LibTypes.SchemaValue[](10);

        keys[0] = "open";
        values[0] = LibTypes.SchemaValue.BOOL;

        keys[1] = "initVerifyAddress";
        values[1] = LibTypes.SchemaValue.ADDRESS;

        keys[2] = "moveVerifyAddress";
        values[2] = LibTypes.SchemaValue.ADDRESS;

        keys[3] = "markVerifyAddress";
        values[3] = LibTypes.SchemaValue.ADDRESS;

        keys[4] = "treasureVerifyAddress";
        values[4] = LibTypes.SchemaValue.ADDRESS;

        keys[5] = "treasureVerifyv2Address";
        values[5] = LibTypes.SchemaValue.ADDRESS;

        keys[6] = "resourceVerifyAddress";
        values[6] = LibTypes.SchemaValue.ADDRESS;

        keys[7] = "resourceVerifyv2Address";
        values[7] = LibTypes.SchemaValue.ADDRESS;

        keys[8] = "attackPathVerifyAddress";
        values[8] = LibTypes.SchemaValue.ADDRESS;

        keys[9] = "coordVerifyAddress";
        values[9] = LibTypes.SchemaValue.ADDRESS;
    }

    function set(ZKConfig memory moveConfig) public {
        set(
            SingletonID,
            abi.encode(
                moveConfig.open,
                moveConfig.initVerifyAddress,
                moveConfig.moveVerifyAddress,
                moveConfig.markVerifyAddress,
                moveConfig.treasureVerifyAddress,
                moveConfig.treasureVerifyv2Address,
                moveConfig.resourceVerifyAddress,
                moveConfig.resourceVerifyv2Address,
                moveConfig.attackPathVerifyAddress,
                moveConfig.coordVerifyAddress
            )
        );
    }

    function getValue() public view returns (ZKConfig memory) {
        (bool open,
            address initVerifyAddress,
            address moveVerifyAddress,
            address markVerifyAddress,
            address treasureVerifyAddress,
            address treasureVerifyv2Address,
            address resourceVerifyAddress,
            address resourceVerifyv2Address,
            address attackPathVerifyAddress,
            address coordVerifyAddress) = abi.decode(
                getRawValue(SingletonID),
                (bool, address, address, address, address, address, address, address, address, address)
            );
        return ZKConfig(open, initVerifyAddress, moveVerifyAddress, markVerifyAddress, treasureVerifyAddress, treasureVerifyv2Address, resourceVerifyAddress, resourceVerifyv2Address, attackPathVerifyAddress, coordVerifyAddress);
    }
}
