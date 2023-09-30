// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "TechUpdatingPlayerComponent", "TechUpdatingComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ResourceConfigv2Component, ID as ResourceConfigv2ComponentID, ResourceConfig} from "components/ResourceConfigv2Component.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {SpaceTimeMarkerComponent, ID as SpaceTimeMarkerComponentID, SpaceTimeMarker} from "components/SpaceTimeMarkerComponent.sol";

import {TechComponent, ID as TechComponentID, Tech} from "components/TechComponent.sol";
import {TechConfigComponent, ID as TechConfigComponentID, TechConfig} from "components/TechConfigComponent.sol";
import {TechConfigGlobalComponent, ID as TechConfigGlobalComponentID, TechConfigGlobal} from "components/TechConfigGlobalComponent.sol";
import {TechUpdatingComponent, ID as TechUpdatingComponentID, TechUpdating} from "components/TechUpdatingComponent.sol";
import {TechBelongingComponent, ID as TechBelongingComponentID} from "components/TechBelongingComponent.sol";
import {TechUpdatingPlayerComponent, ID as TechUpdatingPlayerComponentID} from "components/TechUpdatingPlayerComponent.sol";

import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";

uint256 constant ID = uint256(keccak256("system.TechUpdate"));

struct TechUpdateInfo {
    uint64 nextLevel;
    uint256 techGroupId;
}

contract TechUpdateSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        TechUpdateInfo memory techUpdateInfo = abi.decode(args, (TechUpdateInfo));
        return executeTyped(techUpdateInfo);
    }

    function executeTyped(
        TechUpdateInfo memory techUpdateInfo
    ) public returns (bytes memory) {
        uint256 entityId = addressToEntity(msg.sender);
        
        (uint256 lastTechId, uint256 lastTechGroupId, uint64 lastLevel, uint64 updateTime) = checkLastTech(techUpdateInfo);
        checkUpdateQueue(techUpdateInfo);

        //  验证resource ≥  calculatedResourceCost
        TechConfigComponent techConfigComponent = TechConfigComponent(getAddressById(components, TechConfigComponentID));
        require(techConfigComponent.has(techUpdateInfo.techGroupId), "tech group invalid");
        TechConfig memory techConfig = techConfigComponent.getValue(techUpdateInfo.techGroupId);
        if (updateTime > 0) {
            // 1.3 verify: time diff > updateCooldown
            require(uint64(block.timestamp) - updateTime > levelUpCooldown(techConfig.levelUpCoolDownTime, techUpdateInfo.nextLevel), "this group not cooldown");
        }
        //  生成uid：entity_id + tech_config_id + next_level / world.uniqueEntityID()
        uint256 uid = uint256(keccak256(abi.encodePacked(entityId, 
        lastTechId, 
        techUpdateInfo.nextLevel, 
        world.getUniqueEntityId())));
        //  resource -= calculatedResourceCost
        checkGoldAmount(techConfig.basicResourceCost, techUpdateInfo.nextLevel);
        // set Update info
        executeChanges(uid, techUpdateInfo, techConfig);
    }

    function executeChanges(uint256 uid, TechUpdateInfo memory techUpdateInfo, TechConfig memory techConfig) internal {
        uint256 entityId = addressToEntity(msg.sender);

        TechUpdatingPlayerComponent(
            getAddressById(components, TechUpdatingPlayerComponentID)
        ).set(uid, entityId);
        TechUpdatingComponent(
            getAddressById(components, TechUpdatingComponentID)
        ).set(uid, TechUpdating({
            techGroupId: techUpdateInfo.techGroupId,
            nextLevel: techUpdateInfo.nextLevel,
            finishTime: uint64(block.timestamp) + timeConsumedPerLevel(techConfig.basicLevelUpTime, techUpdateInfo.nextLevel)
        }));
    }

    function checkGoldAmount(uint64 basicResourceCost, uint64 nextLevel) internal {
        uint256 entityId = addressToEntity(msg.sender);
        GoldAmountComponent goldAmountComponent = GoldAmountComponent(getAddressById(components, GoldAmountComponentID));
        uint256 calculatedResourceCost = resourceCostPerLevel(basicResourceCost, nextLevel);
        require(goldAmountComponent.getValue(entityId) >= calculatedResourceCost, "not enough resource");
        goldAmountComponent.set(entityId, goldAmountComponent.getValue(entityId) - calculatedResourceCost);
    }

    function checkLastTech(TechUpdateInfo memory techUpdateInfo) internal returns (uint256, uint256, uint64, uint64) {
        uint256 entityId = addressToEntity(msg.sender);
        // 1. search techs in this tech group
        TechBelongingComponent techBelongingComponent = TechBelongingComponent(getAddressById(components, TechBelongingComponentID));
        TechComponent techComponent = TechComponent(getAddressById(components, TechComponentID));
        // 1.1 get all techs of this entity
        uint256[] memory techIds = techBelongingComponent.getEntitiesWithValue(entityId);
        // 1.2 get techId in same tech group
        uint256 techId = 0;
        uint256 techGroupId = 0;
        uint64 level = 0;
        uint64 updateTime = 0;
        for (uint256 index = 0; index < techIds.length; index++) {
            Tech memory tech = techComponent.getValue(techIds[index]);
            if (tech.techGroupId == techUpdateInfo.techGroupId) {
                techId = techIds[index];
                techGroupId = tech.techGroupId;
                level = tech.level;
                updateTime = tech.updateTime;
                break;
            }
        }
        // 2. if nextLevel = 0: invalid nextLevel
        require(techUpdateInfo.nextLevel > 0, "invalid nextLevel");
        // 3. if nextLevel > 1 && techId > 0: already have tech in this group
        if (techUpdateInfo.nextLevel == 1) {
            require(techId == 0, "already have tech in this group");
        }
        // 4. if nextLevel > 1 && nextLevel != level+1: level skipped
        if (techUpdateInfo.nextLevel > 1) {
            require(techUpdateInfo.nextLevel == level + 1, "level skipped");
        }
        return (techId, techGroupId, level, updateTime);
    }

    function checkUpdateQueue(TechUpdateInfo memory techUpdateInfo) internal {
        uint256 entityId = addressToEntity(msg.sender);
        TechUpdatingPlayerComponent techUpdatingPlayerComponent = TechUpdatingPlayerComponent(getAddressById(components, TechUpdatingPlayerComponentID));
        TechUpdatingComponent techUpdatingComponent = TechUpdatingComponent(getAddressById(components, TechUpdatingComponentID));
        TechConfigGlobal memory techConfigGlobal = TechConfigGlobalComponent(getAddressById(components, TechConfigGlobalComponentID)).getValue();
        // get all 
        uint256[] memory updateIds = techUpdatingPlayerComponent.getEntitiesWithValue(entityId);
        // check max queue length
        require(updateIds.length < techConfigGlobal.maxQueueLength, "the queue is full");
        // check no same techGroup
        for (uint256 index = 0; index < updateIds.length; index++) {
            TechUpdating memory techUpdating = techUpdatingComponent.getValue(updateIds[index]);
            require(techUpdating.techGroupId != techUpdateInfo.techGroupId, "tech group is updating");
        }
    }

    function resourceCostPerLevel(uint64 basicResourceCost, uint64 nextLevel) internal returns (uint256) {
        return (uint256)(basicResourceCost * nextLevel * nextLevel);
    }

    function timeConsumedPerLevel(uint64 basicLevelUpTime, uint64 nextLevel) internal returns (uint64) {
        return basicLevelUpTime * nextLevel * nextLevel;
    }

    function levelUpCooldown(uint64 levelUpCoolDownTime, uint64 nextLevel) internal returns (uint64) {
        return levelUpCoolDownTime * nextLevel * nextLevel;
    }
}

