// SPDX-License-Identifier: GPL-3.0
// components: ["GoldAmountComponent"]
pragma solidity >=0.8.0;
import "solecs/System.sol";
import { IWorld } from "solecs/interfaces/IWorld.sol";
import { IUint256Component } from "solecs/interfaces/IUint256Component.sol";
import { IComponent } from "solecs/interfaces/IComponent.sol";
import { getAddressById } from "solecs/utils.sol";
import {DevConfigComponent, ID as DevConfigComponentID, DevConfig} from "components/DevConfigComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";

uint256 constant ID = uint256(keccak256("system.ResourceDev"));

struct ResourceDevInfo {
    uint256 entityId;
    uint32 resourceType;
    uint256 amount;
}

contract ResourceDevSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
        ResourceDevInfo memory resourceDevInfo = abi.decode(args, (ResourceDevInfo));
        return executeTyped(resourceDevInfo);
    }

  function executeTyped(
    ResourceDevInfo memory resourceDevInfo
  ) public returns (bytes memory) {
    DevConfig memory devConfig = DevConfigComponent(
        world.getComponent(DevConfigComponentID)
    ).getValue();
    require(devConfig.devMode, "not in dev mode");
    if (resourceDevInfo.resourceType == 0) {
        GoldAmountComponent goldAmountComponent = GoldAmountComponent(getAddressById(components, GoldAmountComponentID));
        goldAmountComponent.set(resourceDevInfo.entityId, resourceDevInfo.amount);
    }
  }
}