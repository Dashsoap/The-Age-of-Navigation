// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.TreasureEffectGlobalConfig"));

struct TreasureEffectGlobalConfig {
  uint32[] effectGroups;
  uint64[] effectGroupRarely;
  string[] effectGroupName;
  uint64 minEnergy;
  uint64 maxEnergy;
}

contract TreasureEffectGlobalConfigComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](5);
    values = new LibTypes.SchemaValue[](5);

    keys[0] = "effectGroups";
    values[0] = LibTypes.SchemaValue.UINT32_ARRAY;

    keys[1] = "effectGroupRarely";
    values[1] = LibTypes.SchemaValue.UINT64_ARRAY;

    keys[2] = "effectGroupName";
    values[2] = LibTypes.SchemaValue.STRING_ARRAY;

    keys[3] = "minEnergy";
    values[3] = LibTypes.SchemaValue.UINT64;

    keys[4] = "maxEnergy";
    values[4] = LibTypes.SchemaValue.UINT64;
  }

  function set(TreasureEffectGlobalConfig memory mapConfig) public {
    set(
      SingletonID,
      abi.encode(
        mapConfig.effectGroups,
        mapConfig.effectGroupRarely,
        mapConfig.effectGroupName,
        mapConfig.minEnergy,
        mapConfig.maxEnergy
      )
    );
  }

  function getValue() public view returns (TreasureEffectGlobalConfig memory) {
    (uint32[] memory effectGroups,
      uint64[] memory effectGroupRarely,
      string[] memory effectGroupName,
      uint64 minEnergy,
      uint64 maxEnergy) = abi.decode(getRawValue(SingletonID), (uint32[], uint64[], string[], uint64, uint64));
    return
      TreasureEffectGlobalConfig(effectGroups, effectGroupRarely, effectGroupName, minEnergy, maxEnergy);
  }
}
