// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {Component} from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.TechBuildConfig"));

contract TechBuildConfigComponent is Component {
  constructor(address world) Component(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "value";
    values[0] = LibTypes.SchemaValue.UINT64;
  }

  function set(uint256 entity, uint64 value) public virtual {
    set(entity, abi.encode(value));
  }

  function set(uint64 value) public virtual {
    set(SingletonID, abi.encode(value));
  }

  function getValue(uint256 entity) public view virtual returns (uint64) {
    uint64 value = abi.decode(getRawValue(entity), (uint64));
    return value;
  }

  function getValue() public view virtual returns (uint64) {
    uint64 value = abi.decode(getRawValue(SingletonID), (uint64));
    return value;
  }

  function getEntitiesWithValue(uint64 value) public view virtual returns (uint256[] memory) {
    return getEntitiesWithValue(abi.encode(value));
  }
}
