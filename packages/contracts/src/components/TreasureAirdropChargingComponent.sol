// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureAirdropCharging"));

struct TreasureAirdropCharging {
    uint256 coordHash;
    uint64 area;
}

contract TreasureAirdropChargingComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](2);
        values = new LibTypes.SchemaValue[](2);

        keys[0] = "coordHash";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "area";
        values[1] = LibTypes.SchemaValue.UINT64;
    }

    function set(
        uint256 entity,
        TreasureAirdropCharging memory treasureAirdropCharging
    ) public {
        set(entity, abi.encode(treasureAirdropCharging.coordHash, treasureAirdropCharging.area));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureAirdropCharging memory) {
        (uint256 coordHash, uint64 area) = abi.decode(
            getRawValue(entity),
            (uint256, uint64)
        );
        return TreasureAirdropCharging(coordHash, area);
    }
}
