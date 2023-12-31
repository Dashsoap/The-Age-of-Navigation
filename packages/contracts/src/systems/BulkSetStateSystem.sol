// SPDX-License-Identifier: GPL-3.0
// components: ["*"]
pragma solidity >=0.8.0;
import "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { getAddressById, getSystemAddressById } from "solecs/utils.sol";
import {DevConfigComponent, ID as DevConfigComponentID, DevConfig} from "components/DevConfigComponent.sol";

import { ComponentDevSystem, ID as ComponentDevSystemID } from "./ComponentDevSystem.sol";

uint256 constant ID = uint256(keccak256("system.BulkSetState"));

struct ECSEvent {
  uint8 component;
  uint32 entity;
  bytes value;
}

contract BulkSetStateSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function requirement(bytes memory) public view returns (bytes memory) {
    // NOTE: Make sure to not include this system in a production deployment, as anyone can cahnge all component values
  }

  function execute(bytes memory params) public returns (bytes memory) {
    DevConfig memory devConfig = DevConfigComponent(
        world.getComponent(DevConfigComponentID)
    ).getValue();
    require(devConfig.devMode, "not in dev mode");
    (uint256[] memory componentIds, uint256[] memory entities, ECSEvent[] memory state) = abi.decode(
      params,
      (uint256[], uint256[], ECSEvent[])
    );

    for (uint256 i; i < state.length; i++) {
      IComponent c = IComponent(getAddressById(components, componentIds[state[i].component]));
      c.set(entities[state[i].entity], state[i].value);
    }
  }

  function executeTyped(
    uint256[] memory componentIds,
    uint256[] memory entities,
    ECSEvent[] memory state
  ) external returns (bytes memory) {
    return execute(abi.encode(componentIds, entities, state));
  }
}