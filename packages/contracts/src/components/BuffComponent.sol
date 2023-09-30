// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.Buff"));

struct Buff {
    uint256 buffType;
    uint32 buffLevel;
    string source;
    uint256 sourceID;
    uint256 targetID;
    bool isAdd;
    uint64 buffValue;
    uint64 buffTimeout;
}

contract BuffComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](8);
        values = new LibTypes.SchemaValue[](8);

        keys[0] = "buffType";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "buffLevel";
        values[1] = LibTypes.SchemaValue.UINT32;

        keys[2] = "source";
        values[2] = LibTypes.SchemaValue.STRING;

        keys[3] = "sourceID";
        values[3] = LibTypes.SchemaValue.UINT256;

        keys[4] = "targetID";
        values[4] = LibTypes.SchemaValue.UINT256;

        keys[5] = "isAdd";
        values[5] = LibTypes.SchemaValue.BOOL;

        keys[6] = "buffValue";
        values[6] = LibTypes.SchemaValue.UINT64;

        keys[7] = "buffTimeout";
        values[7] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        Buff memory buff
    ) public {
        set(entity, abi.encode(buff.buffType, buff.buffLevel, buff.source, buff.sourceID, buff.targetID, buff.isAdd, buff.buffValue, buff.buffTimeout));
    }

    function getValue(
        uint256 entity
    ) public view returns (Buff memory) {
        (uint256 buffType, uint32 buffLevel, string memory source, uint256 sourceID, uint256 targetID, bool isAdd, uint64 buffValue, uint64 buffTimeout) = abi.decode(
            getRawValue(entity),
            (uint256, uint32, string, uint256, uint256, bool, uint64, uint64)
        );
        return Buff(buffType, buffLevel, source, sourceID, targetID, isAdd, buffValue, buffTimeout);
    }
}
