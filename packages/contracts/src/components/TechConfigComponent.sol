// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TechConfig"));

struct TechConfig {
    uint256 techGroupId;
    uint64 basicResourceCost;
    uint64 basicLevelUpTime;
    uint64 levelUpCoolDownTime;
    uint32 accelerateResourceRatio;
    uint32 cancelResourceRatio;
}

contract TechConfigComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](6);
        values = new LibTypes.SchemaValue[](6);

        keys[0] = "techGroupId";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "basicResourceCost";
        values[1] = LibTypes.SchemaValue.UINT64;

        keys[2] = "basicLevelUpTime";
        values[2] = LibTypes.SchemaValue.UINT64;

        keys[3] = "levelUpCoolDownTime";
        values[3] = LibTypes.SchemaValue.UINT64;

        keys[4] = "accelerateResourceRatio";
        values[4] = LibTypes.SchemaValue.UINT32;

        keys[5] = "cancelResourceRatio";
        values[5] = LibTypes.SchemaValue.UINT32;
    }

    function set(
        uint256 entity,
        TechConfig memory techConfig
    ) public {
        set(entity, abi.encode(techConfig.techGroupId, techConfig.basicResourceCost, techConfig.basicLevelUpTime, techConfig.levelUpCoolDownTime, techConfig.accelerateResourceRatio, techConfig.cancelResourceRatio));
    }

    function getValue(
        uint256 entity
    ) public view returns (TechConfig memory) {
        (uint256 techGroupId, uint64 basicResourceCost, uint64 basicLevelUpTime, uint64 levelUpCoolDownTime, uint32 accelerateResourceRatio, uint32 cancelResourceRatio) = abi.decode(
            getRawValue(entity),
            (uint256, uint64, uint64, uint64, uint32, uint32)
        );
        return TechConfig(techGroupId, basicResourceCost, basicLevelUpTime, levelUpCoolDownTime, accelerateResourceRatio, cancelResourceRatio);
    }
}