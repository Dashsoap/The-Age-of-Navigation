// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";
import "std-contracts/components/BoolComponent.sol";
import {IUint256Component} from "solecs/interfaces/IUint256Component.sol";
import {getAddressById} from "solecs/utils.sol";
import {ShieldComponent, ID as ShieldComponentID, Shield} from "components/ShieldComponent.sol";

enum TargetType {
    Player, Guild, Shield, ResourceBuilding, ShieldGenerator
}

abstract contract AttackBaseSystem is System {
    uint256 constant HiddenPositionComponentID = uint256(keccak256("component.HiddenPosition"));
    uint256 constant GuildComponentID = uint256(keccak256("component.Guild"));
    uint256 constant PlayerComponentID = uint256(keccak256("component.Player"));
    uint256 constant ResourceBuildingPositionComponentID = uint256(keccak256("component.ResourceBuildingPosition"));
    uint256 constant ShieldAreaPositionComponentID = uint256(keccak256("component.ShieldAreaPosition"));
    uint256 constant ShieldAreaShieldComponentID = uint256(keccak256("component.ShieldAreaShield"));
    uint256 constant HPComponentID = uint256(keccak256("component.HP"));
    uint256 constant ShieldPlayerComponentID = uint256(keccak256("component.ShieldPlayer"));

    function searchTarget(uint256 positionHash, uint256 sourceEntity) virtual internal returns (uint256 target, TargetType targetType) {
        IUint256Component hiddenPositionComponent = IUint256Component(getAddressById(components, HiddenPositionComponentID));
        IUint256Component guildComponent = IUint256Component(getAddressById(components, GuildComponentID));
        BoolComponent playerComponent = BoolComponent(getAddressById(components, PlayerComponentID));
        IUint256Component shieldAreaPositionComponent = IUint256Component(getAddressById(components, ShieldAreaPositionComponentID));
        IUint256Component shieldAreaShieldComponent = IUint256Component(getAddressById(components, ShieldAreaShieldComponentID));
        IUint256Component resourceBuildingPositionComponent = IUint256Component(getAddressById(components, ResourceBuildingPositionComponentID));
        ShieldComponent shieldComponent = ShieldComponent(getAddressById(components, ShieldComponentID));
        IUint256Component shieldPlayerComponent = IUint256Component(getAddressById(components, ShieldPlayerComponentID));
        uint256[] memory entities = hiddenPositionComponent.getEntitiesWithValue(positionHash);
        for (uint256 index = 0; index < entities.length; index++) {
            if (playerComponent.has(entities[index]) && (target == 0)) {
                // entity is player & no other entities in this position
                target = entities[index];
                targetType = TargetType.Player;
            } else if (guildComponent.has(entities[index])) {
                // entity is guild in this position
                target = entities[index];
                targetType = TargetType.Guild;
            } else if (shieldComponent.has(entities[index]) && (target == 0 || (targetType != TargetType.Player && targetType != TargetType.Guild))) {
                // entity is shieldGenerator & no player or guild in this position
                target = entities[index];
                targetType = TargetType.ShieldGenerator;
            } else if (resourceBuildingPositionComponent.has(entities[index]) && (target == 0 || (targetType != TargetType.Player && targetType != TargetType.Guild))) {
                // entity is resourceBuilding & no player or guild in this position
                target = entities[index];
                targetType = TargetType.ResourceBuilding;
            }
        }
        if (target > 0) {
            uint256[] memory shieldAreas = shieldAreaPositionComponent.getEntitiesWithValue(positionHash);
            for (uint256 index1 = 0; index1 < shieldAreas.length; index1++) {
                if (shieldAreaShieldComponent.has(shieldAreas[index1])) {
                    uint256 shieldId = shieldAreaShieldComponent.getValue(shieldAreas[index1]);
                    if (shieldComponent.has(shieldId) && shieldPlayerComponent.has(shieldId)) {
                        Shield memory shield = shieldComponent.getValue(shieldId);
                        if (shield.shieldTimeout >= block.timestamp && shieldPlayerComponent.getValue(shieldId) != sourceEntity) {
                            target = shieldId;
                            targetType = TargetType.Shield;
                            break;
                        }
                    }
                }
            }
        }
        return (target, targetType);
    }

    function dealDamage(uint256 entity, uint256 amount, TargetType entityType) virtual internal returns (uint256 leftAmount) {
        if (entity == 0 || amount == 0) {
            return amount;
        } else if (entityType == TargetType.Shield) {
            ShieldComponent shieldComponent = ShieldComponent(getAddressById(components, ShieldComponentID));
            if (shieldComponent.has(entity)) {
                Shield memory shield = shieldComponent.getValue(entity);
                if (shield.shieldTimeout >= block.timestamp && shield.shieldValue > 0) {
                    if (shield.shieldValue > amount) {
                        shieldComponent.set(entity, Shield({shieldValue: shield.shieldValue - uint32(amount), shieldArea: shield.shieldArea, shieldTimeout: shield.shieldTimeout}));
                    } else {
                        leftAmount = amount - shield.shieldValue;
                        //TODO: not remove shieldPosition
                        IUint256Component hiddenPositionComponent = IUint256Component(getAddressById(components, HiddenPositionComponentID));
                        IUint256Component shieldAreaPositionComponent = IUint256Component(getAddressById(components, ShieldAreaPositionComponentID));
                        IUint256Component shieldAreaShieldComponent = IUint256Component(getAddressById(components, ShieldAreaShieldComponentID));
                        IUint256Component shieldPlayerComponent = IUint256Component(getAddressById(components, ShieldPlayerComponentID));
                        shieldComponent.remove(entity);
                        if (hiddenPositionComponent.has(entity)) {
                            hiddenPositionComponent.remove(entity);
                        }
                        if (shieldPlayerComponent.has(entity)) {
                            shieldPlayerComponent.remove(entity);
                        }
                        uint256[] memory entities = shieldAreaShieldComponent.getEntitiesWithValue(entity);
                        for (uint256 index = 0; index < entities.length; index++) {
                            uint256 areaId = entities[index];
                            if (shieldAreaPositionComponent.has(areaId)) {
                                shieldAreaPositionComponent.remove(areaId);
                            }
                            if (shieldAreaShieldComponent.has(areaId)) {
                                shieldAreaShieldComponent.remove(areaId);
                            }
                        }
                    }
                }
            }
        } else {
            IUint256Component hpComponent = IUint256Component(getAddressById(components, HPComponentID));
            if (hpComponent.has(entity)) {
                uint256 value = hpComponent.getValue(entity);
                if (value > amount) {
                    hpComponent.set(entity, value - amount);
                } else {
                    leftAmount = amount - value;
                    hpComponent.remove(entity);
                }
            }
        }
        return leftAmount;
    }
}
