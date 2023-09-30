// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint32Component } from "std-contracts/components/Uint32Component.sol";
import { SingletonID } from "solecs/SingletonID.sol";

uint256 constant ID = uint256(keccak256("component.TechEffectConfigRegister"));

contract TechEffectConfigRegisterComponent is Uint32Component {
  constructor(address world) Uint32Component(world, ID) {}
}
