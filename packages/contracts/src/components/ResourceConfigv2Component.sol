// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.ResourceConfigv2"));

struct ResourceConfig {
  uint256 valueMax;
  uint256 valueMin;
  uint8 difficultMax;
  uint8 difficultMin;
  uint64 recuitTimeMax;
  uint64 recuitTimeMin;
  uint256 maxBatch;
}

contract ResourceConfigv2Component is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](7);
    values = new LibTypes.SchemaValue[](7);

    keys[0] = "valueMax";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "valueMin";
    values[1] = LibTypes.SchemaValue.UINT256;

    keys[2] = "difficultMax";
    values[2] = LibTypes.SchemaValue.UINT8;

    keys[3] = "difficultMin";
    values[3] = LibTypes.SchemaValue.UINT8;

    keys[4] = "recuitTimeMax";
    values[4] = LibTypes.SchemaValue.UINT64;

    keys[5] = "recuitTimeMin";
    values[5] = LibTypes.SchemaValue.UINT64;

    keys[6] = "maxBatch";
    values[6] = LibTypes.SchemaValue.UINT256;
  }

  function set(ResourceConfig memory resourceConfig) public {
    set(SingletonID, abi.encode(resourceConfig.valueMax, resourceConfig.valueMin, resourceConfig.difficultMax, resourceConfig.difficultMin, resourceConfig.recuitTimeMax, resourceConfig.recuitTimeMin, resourceConfig.maxBatch));
  }

  function getValue() public view returns (ResourceConfig memory) {
    (uint256 valueMax, uint256 valueMin, uint8 difficultMax, uint8 difficultMin, uint64 recuitTimeMax, uint64 recuitTimeMin, uint256 maxBatch) = abi.decode(getRawValue(SingletonID), (uint256, uint256, uint8, uint8, uint64, uint64, uint256));
    return ResourceConfig(valueMax, valueMin, difficultMax, difficultMin, recuitTimeMax, recuitTimeMin, maxBatch);
  }
}
