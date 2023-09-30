// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.BuffConfig"));

struct BuffConfig {
    uint256 buffEffectID;
    string asset;
    string name;
    uint64 buffType;
    uint64 continueTime;
}

contract BuffConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](5);
        values = new LibTypes.SchemaValue[](5);

        keys[0] = "buffEffectID";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "asset";
        values[1] = LibTypes.SchemaValue.STRING;

        keys[2] = "name";
        values[2] = LibTypes.SchemaValue.STRING;

        keys[3] = "buffType";
        values[3] = LibTypes.SchemaValue.UINT64;

        keys[4] = "continueTime";
        values[4] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        BuffConfig memory buffConfig
    ) public {
        set(entity, abi.encode(buffConfig.buffEffectID, buffConfig.asset, buffConfig.name, buffConfig.buffType, buffConfig.continueTime));
    }

    function getValue(
        uint256 entity
    ) public view returns (BuffConfig memory) {
        (uint256 buffEffectID, string memory asset, string memory name, uint64 buffType, uint64 continueTime) = abi.decode(
            getRawValue(entity),
            (uint256, string, string, uint64, uint64)
        );
        return BuffConfig(buffEffectID, asset, name, buffType, continueTime);
    }
}
