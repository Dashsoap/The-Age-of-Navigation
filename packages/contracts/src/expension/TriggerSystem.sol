// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";

struct TriggerInfo {
    uint256 component;
    uint256 entity;
    bytes lastValue;
    bytes newValue;
    bool isSet;
}

abstract contract TriggerSystem is System {
    uint256 constant TriggerSetComponentsComponentID = uint256(keccak256("component.TriggerSetComponents"));
    uint256 constant TriggerRemoveComponentsComponentID = uint256(keccak256("component.TriggerRemoveComponents"));
    uint256 constant TriggerSystemsComponentID = uint256(keccak256("component.TriggerSystems"));

    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        TriggerInfo memory triggerInfo = abi.decode(args, (TriggerInfo));
        return executeTyped(triggerInfo);
    }

    function executeTyped(
        TriggerInfo memory triggerInfo
    ) public returns (bytes memory) {
        // if (triggerInfo.isSet) {
        // }
        return solveLogic(triggerInfo);
    }

    function solveLogic(
        TriggerInfo memory triggerInfo
    ) public virtual returns (bytes memory) {}
}
