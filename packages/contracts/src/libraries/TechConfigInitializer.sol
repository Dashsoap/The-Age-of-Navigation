// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {TechConfigGlobalComponent, ID as TechConfigGlobalComponentID, TechConfigGlobal} from "components/TechConfigGlobalComponent.sol";
import {TechConfigComponent, ID as TechConfigComponentID, TechConfig} from "components/TechConfigComponent.sol";
import {TechConfigRegisterComponent, ID as TechConfigRegisterComponentID} from "components/TechConfigRegisterComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

library TechConfigInitializer {
    function init(IWorld world) internal {
        // 1. set global info
        TechConfigGlobalComponent(
            world.getComponent(TechConfigGlobalComponentID)
        ).set(TechConfigGlobal({maxQueueLength: uint32(3)}));

        TechConfigComponent techConfigComponent = TechConfigComponent(
            world.getComponent(TechConfigComponentID)
        );
        TechConfigRegisterComponent techConfigRegisterComponent = TechConfigRegisterComponent(
            world.getComponent(TechConfigRegisterComponentID)
        );

        TechConfig[1] memory techConfigs = [
            TechConfig({
                techGroupId: 1,
                basicResourceCost: 50,
                basicLevelUpTime: 60,
                levelUpCoolDownTime: 1,
                accelerateResourceRatio: 200, // 除以一百为实际比例
                cancelResourceRatio: 60 // 除以一百为实际比例
            })
        ];

        for (uint256 index = 0; index < techConfigs.length; index++) {
            uint256 uid = world.getUniqueEntityId();
            techConfigComponent.set(uid, techConfigs[index]);
            techConfigRegisterComponent.set(uid, SingletonID);
        }
    }
}
