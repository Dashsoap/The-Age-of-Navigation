// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Warship"));

struct Warship {
  string model;
  uint64 createTime;
}

contract WarshipComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](2);
    values = new LibTypes.SchemaValue[](2);

    keys[0] = "model";
    values[0] = LibTypes.SchemaValue.STRING;

    keys[1] = "createTime";
    values[1] = LibTypes.SchemaValue.UINT64;
  }

  function set(uint256 entity, Warship memory warship) public {
    set(entity, abi.encode(warship.model, warship.createTime));
  }

  function getValue(uint256 entity) public view returns (Warship memory) {
    (string memory model, uint64 createTime) = abi.decode(getRawValue(entity), (string, uint64));
    return Warship(model, createTime);
  }
}
