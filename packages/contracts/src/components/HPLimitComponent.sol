// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { BuffEffectedInt32Component } from "expension/BuffEffectedInt32Component.sol";
import { BuffComponent, ID as BuffComponentID, Buff } from "components/BuffComponent.sol";
import {getAddressById} from "solecs/utils.sol";

uint256 constant ID = uint256(keccak256("component.HPLimit"));

contract HPLimitComponent is BuffEffectedInt32Component {
  constructor(address world) BuffEffectedInt32Component(world, ID) {}

  function searchBuffs(uint256 entity, int32 rawValue) internal view virtual override returns (int32 buffValue) {
    BuffComponent buffComponent = BuffComponent(getAddressById(components, BuffComponentID));
    uint256[] memory buffIds = getBuffIds(entity);
    buffValue = rawValue;
    for (uint256 index = 0; index < buffIds.length; index++) {
        if (buffComponent.has(buffIds[index])) {
            Buff memory buff = buffComponent.getValue(buffIds[index]);
            if ((buff.buffTimeout == 0 || buff.buffTimeout >= block.timestamp) && buff.targetID == ID) {
                if (buff.isAdd) {
                    buffValue = buffValue + int32(uint32(buff.buffValue));
                } else {
                    buffValue = buffValue - int32(uint32(buff.buffValue));
                }
            }
        }
    }
    return buffValue;
  }
}
