// SPDX-License-Identifier: MIT
// components: ["HiddenPositionComponent", "MoveCooldownComponent", "GoldAmountComponent"]
pragma solidity >=0.8.0;
import { addressToEntity } from "solecs/utils.sol";
import { System, IWorld } from "solecs/System.sol";
import { getAddressById } from "solecs/utils.sol";
import { MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig } from "components/MapConfigv2Component.sol";
import { MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig } from "components/MoveConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

import { PlayerComponent, ID as PlayerComponentID } from "components/PlayerComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {GuildComponent, ID as GuildComponentID, Guild} from "components/GuildComponent.sol";
import {GuildCrestComponent, ID as GuildCrestComponentID, GuildCrest} from "components/GuildCrestComponent.sol";
import {GuildCrestPlayerComponent, ID as GuildCrestPlayerComponentID} from "components/GuildCrestPlayerComponent.sol";
import {GuildCrestGuildComponent, ID as GuildCrestGuildComponentID} from "components/GuildCrestGuildComponent.sol";
import { HiddenPositionComponent, ID as HiddenPositionComponentID } from "components/HiddenPositionComponent.sol";
import { WarshipComponent, ID as WarshipComponentID, Warship } from "components/WarshipComponent.sol";
import { MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown } from "components/MoveCooldownComponent.sol";
import {IMoveVerifier} from "verifiers/MoveVerifier.sol";

uint256 constant ID = uint256(keccak256("system.GuildMove"));

struct MoveInfo {
  uint256 coordHash;
  uint256 width;
  uint256 height;
  uint256 seed;
  uint256 oldHash;
  uint256 oldSeed;
  uint256 distance;
  uint256[2] a;
  uint256[2][2] b;
  uint256[2] c;
  uint256 guildCrestId;
}

contract GuildMoveSystem is System {
  constructor(IWorld _world, address _components) System(_world, _components) {}

  function execute(bytes memory args) public returns (bytes memory) {
    MoveInfo memory moveInfo = abi.decode(args, (MoveInfo));
    return executeTyped(moveInfo);
  }

  function executeTyped(MoveInfo memory moveInfo) public returns (bytes memory) {
    ZKConfig memory zkConfig = ZKConfigComponent(
        getAddressById(components, ZKConfigComponentID)
    ).getValue();
    if (zkConfig.open) {
        uint256[7] memory input = [moveInfo.oldHash, moveInfo.coordHash, moveInfo.distance, moveInfo.seed, moveInfo.oldSeed, moveInfo.width, moveInfo.height];
        require(
            IMoveVerifier(zkConfig.moveVerifyAddress).verifyProof(
                moveInfo.a,
                moveInfo.b,
                moveInfo.c,
                input
            ),
            "Failed move proof check"
        );
    }
    uint256 entityId = checkGuildCrest(moveInfo.guildCrestId);

    MoveCooldownComponent moveCooldown = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID));
    MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
    MoveCooldown memory movable = moveCooldown.getValue(entityId);
    // require(
    //   movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
    //   "no action points"
    // );
    require(moveInfo.distance <= moveConfig.maxDistance, "move too far");
    HiddenPositionComponent position = HiddenPositionComponent(
        getAddressById(components, HiddenPositionComponentID)
    );
    require(position.getEntitiesWithValue(moveInfo.coordHash).length == 0, "have entity on tile");

    // Constrain position to map size, wrapping around if necessary
    MapConfig memory mapConfig = MapConfigv2Component(getAddressById(components, MapConfigv2ComponentID)).getValue();
    require(moveInfo.width <= mapConfig.gameRadiusX && moveInfo.height <= mapConfig.gameRadiusY, "radius over limit");

    GoldAmountComponent gold = GoldAmountComponent(
        getAddressById(components, GoldAmountComponentID)
    );
    require(gold.getValue(entityId) > moveConfig.guildCost, "lack of resource");

    position.set(entityId, moveInfo.coordHash);
    gold.set(entityId, gold.getValue(entityId) - moveConfig.guildCost);
    // if (moveInfo.distance > 10) {
    //   uint64 remainPoints = movable.remainingMovePoints +
    //     (uint64(block.timestamp) - movable.lastMoveTime) /
    //     moveConfig.increaseCooldown -
    //     1;
    //   if (remainPoints > moveConfig.maxPoints) {
    //     remainPoints = moveConfig.maxPoints;
    //   }
    //   moveCooldown.set(entityId, MoveCooldown(uint64(uint64(block.timestamp)), remainPoints));
    // }
  }

  function checkGuildCrest(uint256 guildCrestId) internal returns (uint256) {
        uint256 entityId = addressToEntity(msg.sender);
        GuildCrestPlayerComponent guildCrestPlayerComponent = GuildCrestPlayerComponent(getAddressById(components, GuildCrestPlayerComponentID));
        require(guildCrestPlayerComponent.has(guildCrestId) && guildCrestPlayerComponent.getValue(guildCrestId) == entityId, "not owner of guild crest");
        GuildCrestComponent guildCrestComponent = GuildCrestComponent(getAddressById(components, GuildCrestComponentID));
        require(guildCrestComponent.has(guildCrestId) && guildCrestComponent.getValue(guildCrestId).level == 4, "not leader of guild");
        GuildCrestGuildComponent guildCrestGuildComponent = GuildCrestGuildComponent(getAddressById(components, GuildCrestGuildComponentID));
        require(guildCrestGuildComponent.has(guildCrestId), "no guild bounded");
        return guildCrestGuildComponent.getValue(guildCrestId);
    }
}
