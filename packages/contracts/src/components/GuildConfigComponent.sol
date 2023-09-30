// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BareComponent } from "solecs/BareComponent.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.GuildConfig"));

struct GuildConfig {
  uint256 createCost;
  uint32 initTaxRate;
  uint32 basicCountLimit;
  string initNameForLevel0;
  string initNameForLevel1;
  string initNameForLevel2;
  string initNameForLevel3;
  string initNameForLevel4;
  uint32 basicAreaFactor;
  uint32 basicValueFactor;
  uint64 basicRangeFactor;
}

contract GuildConfigComponent is BareComponent {
  constructor(address world) BareComponent(world, ID) {}

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](11);
    values = new LibTypes.SchemaValue[](11);

    keys[0] = "createCost";
    values[0] = LibTypes.SchemaValue.UINT256;

    keys[1] = "initTaxRate";
    values[1] = LibTypes.SchemaValue.UINT32;

    keys[2] = "basicCountLimit";
    values[2] = LibTypes.SchemaValue.UINT32;

    keys[3] = "initNameForLevel0";
    values[3] = LibTypes.SchemaValue.STRING;

    keys[4] = "initNameForLevel1";
    values[4] = LibTypes.SchemaValue.STRING;

    keys[5] = "initNameForLevel2";
    values[5] = LibTypes.SchemaValue.STRING;

    keys[6] = "initNameForLevel3";
    values[6] = LibTypes.SchemaValue.STRING;

    keys[7] = "initNameForLevel4";
    values[7] = LibTypes.SchemaValue.STRING;

    keys[8] = "basicAreaFactor";
    values[8] = LibTypes.SchemaValue.UINT32;

    keys[9] = "basicValueFactor";
    values[9] = LibTypes.SchemaValue.UINT32;

    keys[10] = "basicRangeFactor";
    values[10] = LibTypes.SchemaValue.UINT64;
  }

  function set(GuildConfig memory guildConfig) public {
    set(SingletonID, abi.encode(guildConfig.createCost, guildConfig.initTaxRate, guildConfig.basicCountLimit, guildConfig.initNameForLevel0, guildConfig.initNameForLevel1, guildConfig.initNameForLevel2, guildConfig.initNameForLevel3, guildConfig.initNameForLevel4, guildConfig.basicAreaFactor, guildConfig.basicValueFactor, guildConfig.basicRangeFactor));
  }

  function getValue() public view returns (GuildConfig memory) {
    (uint256 createCost, uint32 initTaxRate, uint32 basicCountLimit, string memory initNameForLevel0, string memory initNameForLevel1, string memory initNameForLevel2, string memory initNameForLevel3, string memory initNameForLevel4, uint32 basicAreaFactor, uint32 basicValueFactor, uint64 basicRangeFactor) = abi.decode(getRawValue(SingletonID), (uint256, uint32, uint32, string, string, string, string, string, uint32, uint32, uint64));
    return GuildConfig(createCost, initTaxRate, basicCountLimit, initNameForLevel0, initNameForLevel1, initNameForLevel2, initNameForLevel3, initNameForLevel4, basicAreaFactor, basicValueFactor, basicRangeFactor);
  }
}
