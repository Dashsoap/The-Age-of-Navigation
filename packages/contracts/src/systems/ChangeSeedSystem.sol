// SPDX-License-Identifier: MIT
// components: ["TerrainComponent"]
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";
import {getAddressById, addressToEntity} from "solecs/utils.sol";
// import {SingletonID} from "solecs/SingletonID.sol";
import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";

uint256 constant ID = uint256(keccak256("system.ChangeSeed"));

contract ChangeSeedSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        uint256 salt = abi.decode(args, (uint256));
        return executeTyped(salt);
    }

    function executeTyped(uint256 salt) public returns (bytes memory) {
        uint256 entityId = addressToEntity(msg.sender);

        TerrainComponent terrain = TerrainComponent(
            world.getComponent(TerrainComponentID)
        );

        terrain.set(uint32(uint256(keccak256(abi.encodePacked(block.number, entityId, salt, block.difficulty, uint256(terrain.getValue()))))));
    }
}
