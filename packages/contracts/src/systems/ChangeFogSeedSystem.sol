// SPDX-License-Identifier: MIT
// components: ["FogSeedComponent"]
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";
import {getAddressById, addressToEntity} from "solecs/utils.sol";
// import {SingletonID} from "solecs/SingletonID.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";

uint256 constant ID = uint256(keccak256("system.ChangeFogSeed"));

contract ChangeFogSeedSystem is System {
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

        FogSeedComponent fogSeed = FogSeedComponent(
            world.getComponent(FogSeedComponentID)
        );

        fogSeed.set(uint32(uint256(keccak256(abi.encodePacked(block.number, entityId, salt, block.difficulty, uint256(fogSeed.getValue()))))));
    }
}
