// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "TechUpdatingPlayerComponent", "TechUpdatingComponent", "TechComponent"]
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

uint256 constant ID = uint256(keccak256("system.TechCancel"));

struct Info {
    uint256 updateId;
}

contract TechCancelSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        Info memory info = abi.decode(args, (Info));
        return executeTyped(info);
    }

    function executeTyped(
        Info memory info
    ) public returns (bytes memory) {
        uint256 updateId = info.updateId;
        uint256 entityId = addressToEntity(msg.sender);
        GoldAmountComponent goldAmountComponent = GoldAmountComponent(getAddressById(components, GoldAmountComponentID));        

        // 1. 获取正在升级的科技
        (uint256 lastUpdateId, uint256 lastTechGroupId, uint64 lastNextLevel, uint64 lastFinishTime) = checkLastTech(updateId);
        require(lastUpdateId != 0, "no tech updating");  

        // 1.5 验证
        TechConfigComponent techConfigComponent = TechConfigComponent(getAddressById(components, TechConfigComponentID));
        require(techConfigComponent.has(lastTechGroupId), "tech group invalid");

        // 1.9 获取techId
        uint256 lastTechId = getTechIdByUpdateId(updateId, lastTechGroupId);

        // 2. 取消升到1级: 使得这个实例 在这个tech_group下 没有 对应的组件值
        //    取消升级到更高等级: 使得这个实例 在这个tech_group下 有 对应值
        TechUpdatingComponent(getAddressById(components, TechUpdatingComponentID)).remove(updateId);
        TechUpdatingPlayerComponent(getAddressById(components, TechUpdatingPlayerComponentID)).remove(updateId);
        if (lastNextLevel > 1) {
            TechComponent(getAddressById(components, TechComponentID)
            ).set(lastTechId, Tech({ 
                techGroupId: lastTechGroupId,
                level: lastNextLevel - 1,
                updateTime: uint64(block.timestamp) // 仅用于检测冷却，暂时不需要存储上上一个升级时间
            }));
        } else if (lastNextLevel < 1) {
            revert("not valid next level");
        }

        // 3. 返还一定比例的resource
        TechConfig memory techConfig = techConfigComponent.getValue(lastTechGroupId);
        uint256 calculatedResourceCost = (uint256)(techConfig.cancelResourceRatio) * resourceCostPerLevel(techConfig.basicResourceCost, lastNextLevel) / 100;
        goldAmountComponent.set(entityId, goldAmountComponent.getValue(entityId) + calculatedResourceCost);

    }

    function checkLastTech(uint256 updateId) internal returns (uint256, uint256, uint64, uint64) {
        uint256 entityId = addressToEntity(msg.sender);
        // 1. search techs in this tech group
        TechUpdatingPlayerComponent techUpdatingPlayerComponent = TechUpdatingPlayerComponent(getAddressById(components, TechUpdatingPlayerComponentID));
        TechUpdatingComponent techUpdatingComponent = TechUpdatingComponent(getAddressById(components, TechUpdatingComponentID));
        // 1.1 get all techs of this entity
        uint256[] memory updateIds = techUpdatingPlayerComponent.getEntitiesWithValue(entityId);
        // 1.2 get techId in same tech group
        uint256 techGroupId = 0;
        uint64 nextLevel = 0;
        uint64 finishTime = 0;
        for (uint256 index = 0; index < updateIds.length; index++) {
            TechUpdating memory techUpdating = techUpdatingComponent.getValue(updateIds[index]);
            if (updateIds[index] == updateId) {
                updateId = updateIds[index];
                techGroupId = techUpdating.techGroupId;
                nextLevel = techUpdating.nextLevel;
                finishTime = techUpdating.finishTime;
                break;
            }
        }
        return (updateId, techGroupId, nextLevel, finishTime);
    }

    function resourceCostPerLevel(uint64 basicResourceCost, uint64 nextLevel) internal returns (uint256) {
        return (uint256)(basicResourceCost * nextLevel * nextLevel);
    }

    function getTechIdByUpdateId(uint256 updateId, uint256 techGroupIdUpdate) internal returns (uint256) {
        uint256 entityId = addressToEntity(msg.sender);
        // 1. search techs in this tech group
        TechBelongingComponent techBelongingComponent = TechBelongingComponent(getAddressById(components, TechBelongingComponentID));
        TechComponent techComponent = TechComponent(getAddressById(components, TechComponentID));
        // 1.1 get all techs of this entity
        uint256[] memory techIds = techBelongingComponent.getEntitiesWithValue(entityId);
        // 1.2 get techId in same tech group
        uint256 techId = 0;
        uint256 techGroupId = 0;
        for (uint256 index = 0; index < techIds.length; index++) {
            Tech memory tech = techComponent.getValue(techIds[index]);
            if (tech.techGroupId == techGroupIdUpdate) {
                techId = techIds[index];
                techGroupId = tech.techGroupId;
                break;
            }
            if (index == techIds.length - 1) {
                revert("Error in getting TechId!");
            }
        }
        return techId;
    }
}

