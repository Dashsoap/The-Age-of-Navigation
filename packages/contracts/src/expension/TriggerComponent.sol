// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "solecs/BareComponent.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import {getAddressById} from "solecs/utils.sol";
import {TriggerSystem, TriggerInfo} from "expension/TriggerSystem.sol";

abstract contract TriggerComponent is BareComponent {
    uint256 constant TriggerSetComponentsComponentID = uint256(keccak256("component.TriggerSetComponents"));
    uint256 constant TriggerRemoveComponentsComponentID = uint256(keccak256("component.TriggerRemoveComponents"));
    uint256 constant TriggerSystemsComponentID = uint256(keccak256("component.TriggerSystems"));
    IUint256Component components;
    IUint256Component systems;
    IWorld worlds;

    // constructor(address world, uint256 id) BareComponent(world, id) {
    //     worlds = IWorld(world);
    //     components = worlds.components();
    //     systems = worlds.systems();
    // }

    function _set(uint256 entity, bytes memory value) internal override virtual {
        bytes memory lastValue = abi.encode(0);
        if (has(entity)) {
            lastValue = getRawValue(entity);
        }
        BareComponent._set(entity, value);
        uint256[] memory mappingIDs = IUint256Component(
            getAddressById(components, TriggerSetComponentsComponentID)
        ).getEntitiesWithValue(id);
        for (uint256 index = 0; index < mappingIDs.length; index++) {
            uint256 systemID = IUint256Component(
                getAddressById(components, TriggerSystemsComponentID)
            ).getValue(mappingIDs[index]);
            TriggerSystem(
                getAddressById(systems, systemID)
            ).executeTyped(TriggerInfo({
                component: id,
                entity: entity,
                lastValue: lastValue,
                newValue: value,
                isSet: true
            }));
        }
    }

    function _remove(uint256 entity) internal override virtual {
        bytes memory lastValue = getRawValue(entity);
        BareComponent._remove(entity);
        uint256[] memory mappingIDs = IUint256Component(
            getAddressById(components, TriggerRemoveComponentsComponentID)
        ).getEntitiesWithValue(id);
        for (uint256 index = 0; index < mappingIDs.length; index++) {
            uint256 systemID = IUint256Component(
                getAddressById(components, TriggerSystemsComponentID)
            ).getValue(mappingIDs[index]);
            TriggerSystem(
                getAddressById(systems, systemID)
            ).executeTyped(TriggerInfo({
                component: id,
                entity: entity,
                lastValue: lastValue,
                newValue: "",
                isSet: false
            }));
        }
    }
}
