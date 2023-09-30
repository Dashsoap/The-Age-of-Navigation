// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.MapConfigv2"));

struct MapConfig {
  uint64 resourceDifficulty;
  uint64 treasureDifficulty;
  uint64 gameOriginX;
  uint64 gameOriginY;
  uint64 gameRadiusX;
  uint64 gameRadiusY;
  uint64 decimals;
}

contract MapConfigv2Component is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](7);
    values = new LibTypes.SchemaValue[](7);

    keys[0] = "resourceDifficulty";
    values[0] = LibTypes.SchemaValue.UINT64;

    keys[1] = "treasureDifficulty";
    values[1] = LibTypes.SchemaValue.UINT64;

    keys[2] = "gameOriginX";
    values[2] = LibTypes.SchemaValue.UINT64;

    keys[3] = "gameOriginY";
    values[3] = LibTypes.SchemaValue.UINT64;

    keys[4] = "gameRadiusX";
    values[4] = LibTypes.SchemaValue.UINT64;

    keys[5] = "gameRadiusY";
    values[5] = LibTypes.SchemaValue.UINT64;

    keys[6] = "decimals";
    values[6] = LibTypes.SchemaValue.UINT64;
  }

  function set(MapConfig memory mapConfig) public {
    set(
      SingletonID,
      abi.encode(
        mapConfig.resourceDifficulty,
        mapConfig.treasureDifficulty,
        mapConfig.gameOriginX,
        mapConfig.gameOriginY,
        mapConfig.gameRadiusX,
        mapConfig.gameRadiusY,
        mapConfig.decimals
      )
    );
  }

  function getValue() public view returns (MapConfig memory) {
    (uint64 resourceDifficulty,
      uint64 treasureDifficulty,
      uint64 gameOriginX,
      uint64 gameOriginY,
      uint64 gameRadiusX,
      uint64 gameRadiusY,
      uint64 decimals) = abi.decode(getRawValue(SingletonID), (uint64, uint64, uint64, uint64, uint64, uint64, uint64));
    return
      MapConfig(resourceDifficulty, treasureDifficulty, gameOriginX, gameOriginY, gameRadiusX, gameRadiusY, decimals);
  }
}
