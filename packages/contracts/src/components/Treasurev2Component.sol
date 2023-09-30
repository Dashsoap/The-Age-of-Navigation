// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Treasurev2"));

struct Treasure {
    string name;
    string asset;
    uint8 useMode;
    uint8 hitMode;
    uint64 cooldownTime;
    uint64 range;
    uint32 usageTimes;
    uint64 energy;
}

contract Treasurev2Component is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](8);
        values = new LibTypes.SchemaValue[](8);

        keys[0] = "name";
        values[0] = LibTypes.SchemaValue.STRING;

        keys[1] = "asset";
        values[1] = LibTypes.SchemaValue.STRING;

        keys[2] = "useMode";
        values[2] = LibTypes.SchemaValue.UINT8;

        keys[3] = "hitMode";
        values[3] = LibTypes.SchemaValue.UINT8;

        keys[4] = "cooldownTime";
        values[4] = LibTypes.SchemaValue.UINT64;

        keys[5] = "range";
        values[5] = LibTypes.SchemaValue.UINT64;

        keys[6] = "usageTimes";
        values[6] = LibTypes.SchemaValue.UINT32;

        keys[7] = "energy";
        values[7] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        Treasure memory treasure
    ) public {
        set(entity, abi.encode(treasure.name, treasure.asset, treasure.useMode, treasure.hitMode, treasure.cooldownTime, treasure.range, treasure.usageTimes, treasure.energy));
    }

    function getValue(
        uint256 entity
    ) public view returns (Treasure memory) {
        (string memory name, string memory asset, uint8 useMode, uint8 hitMode, uint64 cooldownTime, uint64 range, uint32 usageTimes, uint64 energy) = abi.decode(
            getRawValue(entity),
            (string, string, uint8, uint8, uint64, uint64, uint32, uint64)
        );
        return Treasure(name, asset, useMode, hitMode, cooldownTime, range, usageTimes, energy);
    }
}
