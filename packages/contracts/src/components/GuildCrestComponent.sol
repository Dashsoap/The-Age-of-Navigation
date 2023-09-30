// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.GuildCrest"));

struct GuildCrest {
    uint32 level;
    string name;
    uint256 contribute;
    uint256 allocate;
    uint64 createTime;
}

contract GuildCrestComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](5);
        values = new LibTypes.SchemaValue[](5);

        keys[0] = "level";
        values[0] = LibTypes.SchemaValue.UINT32;

        keys[1] = "name";
        values[1] = LibTypes.SchemaValue.STRING;

        keys[2] = "contribute";
        values[2] = LibTypes.SchemaValue.UINT256;

        keys[3] = "allocate";
        values[3] = LibTypes.SchemaValue.UINT256;

        keys[4] = "createTime";
        values[4] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        GuildCrest memory guildCrest
    ) public {
        set(entity, abi.encode(guildCrest.level, guildCrest.name, guildCrest.contribute, guildCrest.allocate, guildCrest.createTime));
    }

    function getValue(
        uint256 entity
    ) public view returns (GuildCrest memory) {
        (uint32 level, string memory name, uint256 contribute, uint256 allocate, uint64 createTime) = abi.decode(
            getRawValue(entity),
            (uint32, string, uint256, uint256, uint64)
        );
        return GuildCrest(level, name, contribute, allocate, createTime);
    }
}
