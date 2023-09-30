// SPDX-License-Identifier: MIT
// components: ["GoldAmountComponent", "ResourceBuildingBoughtComponent"]
pragma solidity >=0.8.0;
import {addressToEntity} from "solecs/utils.sol";
import {System, IWorld} from "solecs/System.sol";
import {getAddressById} from "solecs/utils.sol";
// import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
// import {TreasureEffectConfigComponent, ID as TreasureEffectConfigComponentID, TreasureEffectConfig} from "components/TreasureEffectConfigComponent.sol";
// import {TreasureEffectGenerateConfigComponent, ID as TreasureEffectGenerateConfigComponentID, TreasureEffectGenerateConfig} from "components/TreasureEffectGenerateConfigComponent.sol";
// import {TreasureEffectConfigRegisterComponent, ID as TreasureEffectConfigRegisterComponentID} from "components/TreasureEffectConfigRegisterComponent.sol";
// import {TreasureEffectGlobalConfigComponent, ID as TreasureEffectGlobalConfigComponentID, TreasureEffectGlobalConfig} from "components/TreasureEffectGlobalConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {HiddenPositionComponent, ID as HiddenPositionComponentID} from "components/HiddenPositionComponent.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
// import {FogSeedComponent, ID as FogSeedComponentID} from "components/FogSeedComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

// import {PlayerBelongingComponent, ID as PlayerBelongingComponentID} from "components/PlayerBelongingComponent.sol";
import {GoldAmountComponent, ID as GoldAmountComponentID} from "components/GoldAmountComponent.sol";
import {ResourceBuildingBoughtComponent, ID as ResourceBuildingBoughtComponentID} from "components/ResourceBuildingBoughtComponent.sol";
// import {Treasurev2Component, ID as Treasurev2ComponentID, Treasure} from "components/Treasurev2Component.sol";
// import {TreasureAirdropChargingComponent, ID as TreasureAirdropChargingComponentID, TreasureAirdropCharging} from "components/TreasureAirdropChargingComponent.sol";
// import {ChargingComponent, ID as ChargingComponentID, Charging} from "components/ChargingComponent.sol";
// import {TreasureTimerComponent, ID as TreasureTimerComponentID, TreasureTimer} from "components/TreasureTimerComponent.sol";
// import {TreasureEffectv2Component, ID as TreasureEffectv2ComponentID, TreasureEffect} from "components/TreasureEffectv2Component.sol";
// import {MoveCooldownComponent, ID as MoveCooldownComponentID, MoveCooldown} from "components/MoveCooldownComponent.sol";
import {TreasureEffectSystem, TreasureEffectInfo, CoordVerifyParam, checkCoordZK} from "expension/TreasureEffectSystem.sol";

uint256 constant ID = uint256(keccak256("system.BuyResourceBuilding"));

struct BuyInfo {
    uint256 amount;
}

contract BuyResourceBuildingSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        BuyInfo memory buyInfo = abi.decode(args, (BuyInfo));
        return executeTyped(buyInfo);
    }

    function executeTyped(
        BuyInfo memory buyInfo
    ) public returns (bytes memory) {
        uint256 entityId = addressToEntity(msg.sender);

        //verify belonging & charging finished
        //TODO: verify path.length == 0 and in range & area in area
        ResourceBuildingBoughtComponent countsComponent = ResourceBuildingBoughtComponent(
            getAddressById(components, ResourceBuildingBoughtComponentID)
        );
        uint256 lastCount = 0;
        if (countsComponent.has(entityId)) {
            lastCount = countsComponent.getValue(entityId);
        }
        GoldAmountComponent goldAmountComponent = GoldAmountComponent(
            getAddressById(components, GoldAmountComponentID)
        );
        uint256 totalCosts = 0;
        uint256 basicCount = lastCount + 1;
        for (uint256 index = basicCount; index < buyInfo.amount + basicCount; index++) {
            totalCosts = totalCosts + 10 * index * index;
        }
        require(goldAmountComponent.has(entityId) && goldAmountComponent.getValue(entityId) > totalCosts, "lack of resource");
        // ChargingComponent chargingComponent = ChargingComponent(getAddressById(components, ChargingComponentID));
        // require(countsComponent.has(entityId) && countsComponent.getValue(entityId) > 0, "lack of resource building");
        // Treasurev2Component treasureComponent = Treasurev2Component(
        //     getAddressById(components, Treasurev2ComponentID)
        // );
        // //verify TreasureComponent.use_mode == 1 && TreasureComponent.hitMode == 0
        // Treasure memory treasure = treasureComponent.getValue(settleInfo.treasureId);
        // require(treasure.useMode == 1 && treasure.hitMode == 1, "not for this use mode");
        // //get TreasureEffectComponent.
        // TreasureEffectv2Component treasureEffectComponent = TreasureEffectv2Component(
        //     getAddressById(components, TreasureEffectv2ComponentID)
        // );
        // TreasureEffect memory treasureEffect = treasureEffectComponent.getValue(settleInfo.treasureId);
        // // remove TreasureAirdropCharging
        // TreasureAirdropChargingComponent(
        //     getAddressById(components, TreasureAirdropChargingComponentID)
        // ).remove(settleInfo.treasureId);
        // chargingComponent.remove(entityId);
        //use TreasureEffectSystem
        // TreasureEffectSystem(
        //     getAddressById(world.systems(), uint256(keccak256("system.TreasureEffectAirdropResource")))
        // ).executeTyped(TreasureEffectInfo({
        //         sourceID: ID,
        //         isComponent: false,
        //         entity: entityId,
        //         treasureID: world.getUniqueEntityId(),
        //         path: settleInfo.path,
        //         area: settleInfo.area,
        //         value: 1
        // }));
        //calculate TreasureComponent.usage_times
        // if (treasure.usageTimes == 1) {
        //     PlayerBelongingComponent(
        //         getAddressById(components, PlayerBelongingComponentID)
        //     ).remove(entityId);
        //     treasureComponent.remove(entityId);
        //     TreasureTimerComponent(
        //         getAddressById(components, TreasureTimerComponentID)
        //     ).remove(entityId);
        //     treasureEffectComponent.remove(entityId);
        // } else if (treasure.usageTimes > 1) {
        //TreasureComponent.usage_times
        // treasure.usageTimes = treasure.usageTimes - 1;
        goldAmountComponent.set(entityId, goldAmountComponent.getValue(entityId) - totalCosts);
        countsComponent.set(entityId, lastCount + buyInfo.amount);
        // }

        // MoveCooldown memory movable = MoveCooldownComponent(getAddressById(components, MoveCooldownComponentID)).getValue(entityId);
        // MoveConfig memory moveConfig = MoveConfigComponent(getAddressById(components, MoveConfigComponentID)).getValue();
        // require(
        //     movable.remainingMovePoints > 0 || uint64(block.timestamp) - movable.lastMoveTime > moveConfig.increaseCooldown,
        //     "no action points"
        // );
        // uint64 remainPoints = movable.remainingMovePoints + (uint64(block.timestamp) - movable.lastMoveTime) / moveConfig.increaseCooldown - 1;
        // if (remainPoints > moveConfig.maxPoints) {
        //     remainPoints = moveConfig.maxPoints;
        // }
        // MoveCooldownComponent(
        //     getAddressById(components, MoveCooldownComponentID)
        // ).set(entityId, MoveCooldown(uint64(block.timestamp), remainPoints));
    }
}
