// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "ResourceBuildingCountsComponent", "PlayerComponent", "HiddenPositionComponent", "WarshipComponent", "MoveCooldownComponent", "HPComponent", "HPLimitComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

import {PlayerComponent, ID as PlayerComponentID} from "components/PlayerComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {HPComponent, ID as HPComponentID} from "components/HPComponent.sol";
import {HPLimitComponent, ID as HPLimitComponentID} from "components/HPLimitComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {ResourceBuildingCountsComponent, ID as ResourceBuildingCountsComponentID} from "components/ResourceBuildingCountsComponent.sol";
import {WarshipComponent, ID as WarshipComponentID, Warship} from "components/WarshipComponent.sol";
import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {IInitVerifier} from "verifiers/InitVerifier.sol";

uint256 constant ID = uint256(keccak256("system.JoinGamev2"));

struct JoinInfo {
    uint256 coordHash;
    uint256 width;
    uint256 height;
    uint256 seed;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

contract JoinGamev2System is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        JoinInfo memory joinInfo = abi.decode(args, (JoinInfo));
        return executeTyped(joinInfo);
    }

    function executeTyped(
        JoinInfo memory joinInfo
    ) public returns (bytes memory) {
        ZKConfig memory zkConfig = ZKConfigComponent(
            getAddressById(components, ZKConfigComponentID)
        ).getValue();
        if (zkConfig.open) {
            uint256[4] memory input = [joinInfo.coordHash, joinInfo.seed, joinInfo.width, joinInfo.height];
            require(
                IInitVerifier(zkConfig.initVerifyAddress).verifyProof(
                    joinInfo.a,
                    joinInfo.b,
                    joinInfo.c,
                    input
                ),
                "Failed init proof check"
            );
        }
        uint256 entityId = addressToEntity(msg.sender);

        PlayerComponent player = PlayerComponent(
            getAddressById(components, PlayerComponentID)
        );
        require(!player.has(entityId), "already joined");

        // Constrain position to map size, wrapping around if necessary
        MapConfig memory mapConfig = MapConfigv2Component(
            getAddressById(components, MapConfigv2ComponentID)
        ).getValue();
        require(
            joinInfo.width <= mapConfig.gameRadiusX &&
                joinInfo.height <= mapConfig.gameRadiusY,
            "radius over limit"
        );
        MoveConfig memory moveConfig = MoveConfigComponent(
            getAddressById(components, MoveConfigComponentID)
        ).getValue();

        player.set(entityId);
        HiddenPositionComponent(
            getAddressById(components, HiddenPositionComponentID)
        ).set(entityId, joinInfo.coordHash);
        // WarshipComponent
        // MoveCooldownComponent
        // uint256 warshipId = world.getUniqueEntityId();
        WarshipComponent(getAddressById(components, WarshipComponentID)).set(
            entityId,
            Warship("warship", uint64(block.timestamp))
        );
        HPComponent(getAddressById(components, HPComponentID)).set(
            entityId,
            2
        );
        HPLimitComponent(getAddressById(components, HPLimitComponentID)).set(
            entityId,
            2
        );
        GoldAmountComponent(getAddressById(components, GoldAmountComponentID)).set(
            entityId,
            0
        );
        ResourceBuildingCountsComponent(getAddressById(components, ResourceBuildingCountsComponentID)).set(
            entityId,
            2
        );
        MoveCooldownComponent(
            getAddressById(components, MoveCooldownComponentID)
        ).set(entityId, MoveCooldown(uint64(block.timestamp), moveConfig.initPoints));
    }
}
