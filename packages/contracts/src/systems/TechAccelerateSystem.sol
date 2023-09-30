// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "TechUpdatingPlayerComponent", "TechUpdatingComponent", "TechBelongingComponent", "TechComponent"]
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
import {TechEffectAddHPSystem, ID as TechEffectAddHPSystemID} from "systems/TechEffectAddHPSystem.sol";
import {TechEffectExtraResourceSystem, ID as TechEffectExtraResourceSystemID} from "systems/TechEffectExtraResourceSystem.sol";

import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {BuffBelongingComponent, ID as BuffBelongingComponentID} from "components/BuffBelongingComponent.sol";
import {BuffComponent, ID as BuffComponentID, Buff} from "components/BuffComponent.sol";

uint256 constant ID = uint256(keccak256("system.TechAccelerate"));

struct Info {
    uint256 updateId;
}

contract TechAccelerateSystem is System {
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

        // 2. 验证是否存在足够资源
        TechConfigComponent techConfigComponent = TechConfigComponent(getAddressById(components, TechConfigComponentID));
        require(techConfigComponent.has(lastTechGroupId), "tech group invalid");
        TechConfig memory techConfig = techConfigComponent.getValue(lastTechGroupId);
        uint256 calculatedResourceCost = (uint256)(techConfig.accelerateResourceRatio) * resourceCostPerLevel(techConfig.basicResourceCost, lastNextLevel, lastFinishTime, techConfig.basicLevelUpTime) / 100;
        require(goldAmountComponent.getValue(entityId) >= calculatedResourceCost, "not enough resource");
        // 2.2 完成时间的逻辑不再验证，因为升级完成也会移除升级组件

        // 3. 扣除resource
        goldAmountComponent.set(entityId, goldAmountComponent.getValue(entityId) - calculatedResourceCost);
        
        // 3.9 获取techId
        uint256 lastTechId = getTechIdByUpdateId(updateId, lastTechGroupId);
        if (lastTechId == 0) {
            lastTechId = world.getUniqueEntityId();
        }

        // 4. 调整各组件状态
        TechUpdatingComponent(getAddressById(components, TechUpdatingComponentID)).remove(updateId);
        TechUpdatingPlayerComponent(getAddressById(components, TechUpdatingPlayerComponentID)).remove(updateId);
        TechComponent(getAddressById(components, TechComponentID)
        ).set(lastTechId, Tech({
            techGroupId: lastTechGroupId,
            level: lastNextLevel,
            updateTime: uint64(block.timestamp)
        }));
        TechBelongingComponent(getAddressById(components, TechBelongingComponentID)).set(lastTechId, entityId);

        // 不需要手动释放 UpdateQueue

        // 5. 执行科技效果
        executeTechEffect(updateId, lastTechId, entityId);
    }
    
    function executeTechEffect(uint256 updateId, uint256 lastTechId, uint256 entityId) internal {
        BuffBelongingComponent buffBelongingComponent = BuffBelongingComponent(getAddressById(components, BuffBelongingComponentID));
        uint256[] memory buffs = buffBelongingComponent.getEntitiesWithValue(entityId);
        BuffComponent buffComponent = BuffComponent(getAddressById(components, BuffComponentID));
        for (uint256 index = 0; index < buffs.length; index++) {
            Buff memory buff = buffComponent.getValue(buffs[index]);
            if (keccak256(abi.encodePacked(buff.source)) == keccak256(abi.encodePacked("tech")) && keccak256(abi.encodePacked(buff.source)) == keccak256(abi.encodePacked(lastTechId))){
                // remove tech buff
                BuffBelongingComponent(getAddressById(components, BuffBelongingComponentID)).remove(buffs[index]);
                BuffComponent(getAddressById(components, BuffComponentID)).remove(buffs[index]);
                // add new tech buff
                if (buff.buffType == 1){
                    TechEffectAddHPSystem techEffectAddHPSystem = TechEffectAddHPSystem(getAddressById(world.systems(), TechEffectAddHPSystemID));
                    //调用TechEffectAddHPSystem 的 effectLogic
                } else if (buff.buffType == 2){
                    TechEffectExtraResourceSystem techEffectExtraResourceSystem = TechEffectExtraResourceSystem(getAddressById(world.systems(), TechEffectExtraResourceSystemID));
                    //调用TechEffectExtraResourceSystem 的 effectLogic
                } else {
                    revert("Wrong BuffType in Tech!");
                }
            }
        }
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
                techGroupId = techUpdating.techGroupId;
                nextLevel = techUpdating.nextLevel;
                finishTime = techUpdating.finishTime;
                break;
            }
        }
        return (updateId, techGroupId, nextLevel, finishTime);
    }

    function timeConsumedPerLevel(uint64 basicLevelUpTime, uint64 nextLevel) internal returns (uint64) {
        return basicLevelUpTime * nextLevel * nextLevel;
    }

    function resourceCostPerLevel(
        uint64 basicResourceCost, uint64 nextLevel, uint64 lastFinishTime, uint64 basicLevelUpTime
    ) internal returns (uint256) {
        uint64 denominatorTime = timeConsumedPerLevel(basicLevelUpTime, nextLevel);
        require(uint64(block.timestamp) < lastFinishTime, "Update already finished");
        uint64 numeratorTime = lastFinishTime - uint64(block.timestamp);
        require(numeratorTime <= denominatorTime, "Acceleration Failed!!!");
        numeratorTime = (30000 * numeratorTime + 10000 * denominatorTime) / 40000;
        // 斜率为-3/4递减，即使快结束了想要加速也得掏出1/4本金
        return (uint256)(basicResourceCost * nextLevel * nextLevel * numeratorTime / denominatorTime);
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