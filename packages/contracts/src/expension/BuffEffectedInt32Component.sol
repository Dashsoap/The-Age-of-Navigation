// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {LibTypes} from "solecs/LibTypes.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import {BareComponent} from "solecs/BareComponent.sol";
import {IUint256Component} from "solecs/interfaces/IUint256Component.sol";
import {getAddressById} from "solecs/utils.sol";

contract BuffEffectedInt32Component is BareComponent {
    uint256 constant BuffComponentID = uint256(keccak256("component.Buff"));
    uint256 constant BuffBelongingComponentID = uint256(keccak256("component.BuffBelonging"));
    IUint256Component components;
    IUint256Component systems;
    IWorld worlds;

    constructor(address world, uint256 id) BareComponent(world, id) {
        worlds = IWorld(world);
        components = worlds.components();
        systems = worlds.systems();
    }

    function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
        keys = new string[](1);
        values = new LibTypes.SchemaValue[](1);

        keys[0] = "value";
        values[0] = LibTypes.SchemaValue.INT32;
    }

    function set(uint256 entity, int32 value) public virtual {
        set(entity, abi.encode(value));
    }

    function getBuffValue(uint256 entity) public view virtual returns (int32) {
        int32 value = abi.decode(getRawValue(entity), (int32));
        return searchBuffs(entity, value);
    }

    function getValue(uint256 entity) public view virtual returns (int32) {
        int32 value = abi.decode(getRawValue(entity), (int32));
        return value;
    }

    function searchBuffs(uint256 entity, int32 rawValue) internal view virtual returns (int32 buffValue) {}

    function getBuffIds(uint256 entity) internal view virtual returns (uint256[] memory buffIds) {
        return IUint256Component(
            getAddressById(components, BuffBelongingComponentID)
        ).getEntitiesWithValue(entity);
    }
}
