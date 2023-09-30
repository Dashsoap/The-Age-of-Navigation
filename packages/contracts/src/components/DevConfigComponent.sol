// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.DevConfig"));

struct DevConfig {
  bool devMode;
}

contract DevConfigComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "devMode";
    values[0] = LibTypes.SchemaValue.BOOL;
  }

  function set(DevConfig memory devConfig) public {
    set(SingletonID, abi.encode(devConfig.devMode));
  }

  function getValue() public view returns (DevConfig memory) {
    (bool devMode) = abi.decode(getRawValue(SingletonID), (bool));
    return DevConfig(devMode);
  }
}
