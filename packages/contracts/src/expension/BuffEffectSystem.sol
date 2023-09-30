// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";

struct BuffEffectInfo {
    uint256 entity;
    bool isComponent;
    uint256 buffEntity;
}

abstract contract BuffEffectSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        BuffEffectInfo memory effectInfo = abi.decode(args, (BuffEffectInfo));
        return executeTyped(effectInfo);
    }

    function executeTyped(
        BuffEffectInfo memory effectInfo
    ) public returns (bytes memory) {
        return effectLogic(effectInfo);
    }

    function effectLogic(BuffEffectInfo memory effectInfo) virtual internal returns (bytes memory) {}
}
