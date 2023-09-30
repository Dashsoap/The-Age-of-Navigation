// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import { Uint256Component } from "std-contracts/components/Uint256Component.sol";


uint256 constant ID = uint256(keccak256("component.TechUpdatingPlayer"));

// struct TechUpdatingPlayer {
//     uint256 techGroupID;
//     uint256[] ownerIDs;  // Player or Guild
// }

contract TechUpdatingPlayerComponent is Uint256Component {
    constructor(address world) Uint256Component(world, ID) {}
}

// 1. TechBelongingComponent - 参考PlayerBelongingComponent，直接继承Uint256Component就足够了，用法可以参考:
// a. 加载Component
//     PlayerBelongingComponent playerBelonging = PlayerBelongingComponent(
//         getAddressById(components, PlayerBelongingComponentID)
//     );
// b. 验证是否存在绑定关系
//     require(!playerBelonging.has(treasureId), "Already pickedUp");
// c. 绑定
//     playerBelonging.set(treasureId, entityId);