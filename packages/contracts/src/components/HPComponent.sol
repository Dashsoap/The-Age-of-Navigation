// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import { Component } from "solecs/Component.sol";
import { LibTypes } from "solecs/LibTypes.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import {getAddressById} from "solecs/utils.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import {HPLimitComponent, ID as HPLimitComponentID} from "components/HPLimitComponent.sol";
import {TriggerSystem, TriggerInfo} from "expension/TriggerSystem.sol";

uint256 constant ID = uint256(keccak256("component.HP"));

/**
 * Reference implementation of a component storing a uint256 value for each entity.
 */
contract HPComponent is Component, IUint256Component {
  uint256 constant TriggerSetComponentsComponentID = uint256(keccak256("component.TriggerSetComponents"));
  uint256 constant TriggerRemoveComponentsComponentID = uint256(keccak256("component.TriggerRemoveComponents"));
  uint256 constant TriggerSystemsComponentID = uint256(keccak256("component.TriggerSystems"));
  IUint256Component components;
  IUint256Component systems;
  IWorld worlds;

  constructor(address world) Component(world, ID) {
    worlds = IWorld(world);
    components = worlds.components();
    systems = worlds.systems();
  }

  function getSchema() public pure override returns (string[] memory keys, LibTypes.SchemaValue[] memory values) {
    keys = new string[](1);
    values = new LibTypes.SchemaValue[](1);

    keys[0] = "value";
    values[0] = LibTypes.SchemaValue.UINT256;
  }

  function set(uint256 entity, uint256 value) public virtual {
    set(entity, abi.encode(value));
  }

  function getValue(uint256 entity) public view virtual returns (uint256) {
    uint256 value = abi.decode(getRawValue(entity), (uint256));
    int32 limit = HPLimitComponent(
        getAddressById(components, HPLimitComponentID)
    ).getBuffValue(entity);
    if (limit <= 0) {
      value = 0;
    } else if (uint256(uint32(limit)) < value) {
      value = uint256(uint32(limit));
    }
    return value;
  }

  function _set(uint256 entity, bytes memory value) internal override virtual {
        bytes memory lastValue = abi.encode(0);
        if (has(entity)) {
            lastValue = getRawValue(entity);
        }
        Component._set(entity, value);
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
        Component._remove(entity);
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

  function getEntitiesWithValue(uint256 value) public view virtual returns (uint256[] memory) {
    return getEntitiesWithValue(abi.encode(value));
  }
}
