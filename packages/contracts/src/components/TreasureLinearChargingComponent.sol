// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureLinearCharging"));

struct TreasureLinearCharging {
    uint256 coordHash;
    uint32 direction;
    uint64 distance;
    uint32 area;
}

contract TreasureLinearChargingComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](4);
        values = new LibTypes.SchemaValue[](4);

        keys[0] = "coordHash";
        values[0] = LibTypes.SchemaValue.UINT256;

        keys[1] = "direction";
        values[1] = LibTypes.SchemaValue.UINT32;

        keys[2] = "distance";
        values[2] = LibTypes.SchemaValue.UINT64;

        keys[3] = "area";
        values[3] = LibTypes.SchemaValue.UINT32;
    }

    function set(
        uint256 entity,
        TreasureLinearCharging memory treasureLinearCharging
    ) public {
        set(entity, abi.encode(treasureLinearCharging.coordHash, treasureLinearCharging.direction, treasureLinearCharging.distance, treasureLinearCharging.area));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureLinearCharging memory) {
        (uint256 coordHash, uint32 direction, uint64 distance, uint32 area) = abi.decode(
            getRawValue(entity),
            (uint256, uint32, uint64, uint32)
        );
        return TreasureLinearCharging(coordHash, direction, distance, area);
    }
}
