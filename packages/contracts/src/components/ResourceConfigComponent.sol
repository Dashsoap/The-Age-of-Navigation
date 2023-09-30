// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.ResourceConfig"));

struct ResourceConfig {
  uint256 valueMax;
  uint256 valueMin;
  uint8 difficultMax;
  uint8 difficultMin;
}

contract ResourceConfigComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](4);
    values = new LibTypes.SchemaValue[](4);

    keys[0] = "valueMax";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "valueMin";
    values[1] = LibTypes.SchemaValue.UINT256;

    keys[2] = "difficultMax";
    values[2] = LibTypes.SchemaValue.UINT8;

    keys[3] = "difficultMin";
    values[3] = LibTypes.SchemaValue.UINT8;
  }

  function set(ResourceConfig memory resourceConfig) public {
    set(SingletonID, abi.encode(resourceConfig.valueMax, resourceConfig.valueMin, resourceConfig.difficultMax, resourceConfig.difficultMin));
  }

  function getValue() public view returns (ResourceConfig memory) {
    (uint256 valueMax, uint256 valueMin, uint8 difficultMax, uint8 difficultMin) = abi.decode(getRawValue(SingletonID), (uint256, uint256, uint8, uint8));
    return ResourceConfig(valueMax, valueMin, difficultMax, difficultMin);
  }
}
