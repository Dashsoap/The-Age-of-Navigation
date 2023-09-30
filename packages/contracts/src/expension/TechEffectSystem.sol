// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";
import {IUint256Component} from "solecs/interfaces/IUint256Component.sol";
import {getAddressById} from "solecs/utils.sol";

struct TechEffectInfo {
    uint256 sourceId;
    bool isComponent;
    uint256 entity;
    uint256 techEffectId;
    uint64 value;
}

interface ITechEffectSystem {
    function execute(bytes memory args) external returns (bytes memory);

    function executeTyped(TechEffectInfo memory effectInfo) external returns (bytes memory);
}

abstract contract TechEffectSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        TechEffectInfo memory effectInfo = abi.decode(args, (TechEffectInfo));
        return executeTyped(effectInfo);
    }

    function executeTyped(
        TechEffectInfo memory effectInfo
    ) public returns (bytes memory) {
        return effectLogic(effectInfo);
    }

    function effectLogic(TechEffectInfo memory techEffectInfo) virtual public returns (bytes memory) {}
}
