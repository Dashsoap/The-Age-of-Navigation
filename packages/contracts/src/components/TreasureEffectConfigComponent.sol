// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureEffectConfig"));

struct TreasureEffectConfig {
    uint256 effectID;
    string effectName;
    string effectAsset;
    uint32 effectGroup;
    uint64 effectRarely;
    uint8 useMode;
    uint8 hitMode;
}

contract TreasureEffectConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](7);
        values = new LibTypes.SchemaValue[](7);

        keys[0] = "effectID";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "effectName";
        values[1] = LibTypes.SchemaValue.STRING;

        keys[2] = "effectAsset";
        values[2] = LibTypes.SchemaValue.STRING;

        keys[3] = "effectGroup";
        values[3] = LibTypes.SchemaValue.UINT32;
        
        keys[4] = "effectRarely";
        values[4] = LibTypes.SchemaValue.UINT64;

        keys[5] = "useMode";
        values[5] = LibTypes.SchemaValue.UINT8;

        keys[6] = "hitMode";
        values[6] = LibTypes.SchemaValue.UINT8;
    }

    function set(
        uint256 entity,
        TreasureEffectConfig memory treasureEffect
    ) public {
        set(entity, abi.encode(treasureEffect.effectID,
            treasureEffect.effectName,
            treasureEffect.effectAsset,
            treasureEffect.effectGroup,
            treasureEffect.effectRarely,
            treasureEffect.useMode,
            treasureEffect.hitMode));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureEffectConfig memory) {
        (uint256 effectID,
            string memory effectName,
            string memory effectAsset,
            uint32 effectGroup,
            uint64 effectRarely,
            uint8 useMode,
            uint8 hitMode) = abi.decode(
            getRawValue(entity),
            (uint256, string, string, uint32, uint64, uint8, uint8)
        );
        return TreasureEffectConfig(effectID, effectName, effectAsset, effectGroup, effectRarely, useMode, hitMode);
    }
}
