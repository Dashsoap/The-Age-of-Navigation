// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Guild"));

struct Guild {
    uint256 leader;
    string flag;
    string name;
    string description;
    uint64 createTime;
    uint32 regime;
    uint32 taxRate;
    uint256 resource;
}

contract GuildComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](8);
        values = new LibTypes.SchemaValue[](8);

        keys[0] = "leader";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "flag";
        values[1] = LibTypes.SchemaValue.STRING;

        keys[2] = "name";
        values[2] = LibTypes.SchemaValue.STRING;

        keys[3] = "description";
        values[3] = LibTypes.SchemaValue.STRING;

        keys[4] = "createTime";
        values[4] = LibTypes.SchemaValue.UINT64;

        keys[5] = "regime";
        values[5] = LibTypes.SchemaValue.UINT32;

        keys[6] = "taxRate";
        values[6] = LibTypes.SchemaValue.UINT32;

        keys[7] = "resource";
        values[7] = LibTypes.SchemaValue.UINT256;
    }

    function set(
        uint256 entity,
        Guild memory guild
    ) public {
        set(entity, abi.encode(guild.leader, guild.flag, guild.name, guild.description, guild.createTime, guild.regime, guild.taxRate, guild.resource));
    }

    function getValue(
        uint256 entity
    ) public view returns (Guild memory) {
        (uint256 leader, string memory flag, string memory name, string memory description, uint64 createTime, uint32 regime, uint32 taxRate, uint256 resource) = abi.decode(
            getRawValue(entity),
            (uint256, string, string, string, uint64, uint32, uint32, uint256)
        );
        return Guild(leader, flag, name, description, createTime, regime, taxRate, resource);
    }
}
