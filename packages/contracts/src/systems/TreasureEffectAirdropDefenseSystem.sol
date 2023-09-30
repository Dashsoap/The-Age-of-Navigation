// SPDX-License-Identifier: MIT
// components: ["ShieldComponent", "ShieldPlayerComponent", "ShieldAreaPositionComponent", "ShieldAreaShieldComponent", "HiddenPositionComponent", "SpaceTimeMarkerComponent", "HPComponent", "HPLimitComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";

import {HPComponent, ID as HPComponentID} from "components/HPComponent.sol";
import {HPLimitComponent, ID as HPLimitComponentID} from "components/HPLimitComponent.sol";
import {ShieldPlayerComponent, ID as ShieldPlayerComponentID} from "components/ShieldPlayerComponent.sol";
import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {ShieldAreaPositionComponent, ID as ShieldAreaPositionComponentID} from "components/ShieldAreaPositionComponent.sol";
import {ShieldAreaShieldComponent, ID as ShieldAreaShieldComponentID} from "components/ShieldAreaShieldComponent.sol";
import {ShieldComponent, ID as ShieldComponentID, Shield} from "components/ShieldComponent.sol";
import {SpaceTimeMarkerComponent, ID as SpaceTimeMarkerComponentID, SpaceTimeMarker} from "components/SpaceTimeMarkerComponent.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.TreasureEffectAirdropDefense"));
// uint256 constant BuffID = uint256(keccak256("system.BuffEffectAddHPCalculateSystem"));

contract TreasureEffectAirdropDefenseSystem is TreasureEffectSystem {
    event Debug(string prex, uint256 value);

    constructor(
        IWorld _world,
        address _components
    ) TreasureEffectSystem(_world, _components) {}

    function effectLogic(
        TreasureEffectInfo memory effectInfo
    ) internal override returns (bytes memory) {
        uint256 entityId = effectInfo.entity;
        uint256 shieldId = world.getUniqueEntityId();
        // check HiddenPosition(path[0])
        emit Debug("path:", effectInfo.path.length);
        emit Debug("area:", effectInfo.area.length);
        require(effectInfo.path.length == 1, "target coord invalid");
        checkHiddenPosition(effectInfo.path[0].fogHash);
        checkSpaceTimeMark(effectInfo.path[0].realHash, effectInfo.path[0].fogSeed);
        // airdrop defense area
        // create ShieldArea entities
        for (uint256 index = 0; index < effectInfo.area.length; index++) {
            emit Debug("checking:", effectInfo.area[index].fogHash);
            CoordVerifyParam memory coord = effectInfo.area[index];
            checkCoordZK(coord, components);
            checkSpaceTimeMark(coord.realHash, coord.fogSeed);
        }
        setSpaceTimeMark(effectInfo.path[0].realHash, effectInfo.path[0].fogSeed);
        for (uint256 index1 = 0; index1 < effectInfo.area.length; index1++) {
            emit Debug("adding effect area:", effectInfo.area[index1].fogHash);
            CoordVerifyParam memory coord1 = effectInfo.area[index1];
            setSpaceTimeMark(coord1.realHash, coord1.fogSeed);
            setShieldArea(coord1, shieldId);
        }
        // create Shield entity
        emit Debug("adding shield:", effectInfo.path[0].fogHash);
        setHiddenPosition(effectInfo.path[0].fogHash, shieldId);
        emit Debug("shield value:", effectInfo.value);
        setShield(entityId, effectInfo.value, effectInfo.areaAmount, uint64(0), shieldId);
    }

    function checkHiddenPosition(uint256 fogCoord) internal {
        HiddenPositionComponent hiddenPositionComponent = HiddenPositionComponent(
            getAddressById(components, HiddenPositionComponentID)
        );
        uint256[] memory entities = hiddenPositionComponent.getEntitiesWithValue(fogCoord);
        require(entities.length == 0, "has Entity in target coord");
    }

    function checkSpaceTimeMark(uint256 realCoord, uint256 fogSeed) internal {
        SpaceTimeMarkerComponent spaceTimeMarker = SpaceTimeMarkerComponent(
            getAddressById(components, SpaceTimeMarkerComponentID)
        );
        if (spaceTimeMarker.has(realCoord)) {
            SpaceTimeMarker memory mark = spaceTimeMarker.getValue(realCoord);
            require(mark.seed == uint32(fogSeed) && (mark.isUnlimited || (!mark.isUnlimited && mark.timeout >= uint64(block.timestamp))), "fog seed invalid");
        } else {
            require(FogSeedComponent(world.getComponent(FogSeedComponentID)).getValue() == uint32(fogSeed), "fog seed invalid");
        }
    }

    function setSpaceTimeMark(uint256 realCoord, uint256 fogSeed) internal {
        SpaceTimeMarkerComponent spaceTimeMarker = SpaceTimeMarkerComponent(
            getAddressById(components, SpaceTimeMarkerComponentID)
        );
        spaceTimeMarker.set(realCoord, SpaceTimeMarker(uint32(fogSeed), 0, true));
    }

    function setShieldArea(CoordVerifyParam memory coord, uint256 shieldId) internal {
        uint256 shieldAreaId = world.getUniqueEntityId();
        ShieldAreaPositionComponent(
            getAddressById(components, ShieldAreaPositionComponentID)
        ).set(shieldAreaId, coord.fogHash);
        ShieldAreaShieldComponent(
            getAddressById(components, ShieldAreaShieldComponentID)
        ).set(shieldAreaId, shieldId);
    }

    function setHiddenPosition(uint256 fogCoord, uint256 shieldId) internal {
        HiddenPositionComponent hiddenPositionComponent = HiddenPositionComponent(
            getAddressById(components, HiddenPositionComponentID)
        );
        hiddenPositionComponent.set(shieldId, fogCoord);
    }

    function setShield(uint256 entityId, uint32 shieldValue, uint32 shieldArea, uint64 shieldTimeout, uint256 shieldId) internal {
        ShieldComponent(
            getAddressById(components, ShieldComponentID)
        ).set(shieldId, Shield({ shieldValue: shieldValue, shieldArea: shieldArea, shieldTimeout: shieldTimeout }));
        ShieldPlayerComponent(
            getAddressById(components, ShieldPlayerComponentID)
        ).set(shieldId, entityId);
        HPComponent(getAddressById(components, HPComponentID)).set(entityId, 2);
        HPLimitComponent(getAddressById(components, HPLimitComponentID)).set(entityId, 2);
    }
}
