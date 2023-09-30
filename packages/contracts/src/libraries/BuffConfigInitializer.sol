// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {BuffConfigComponent, ID as BuffConfigComponentID, BuffConfig} from "components/BuffConfigComponent.sol";
import {BuffConfigRegisterComponent, ID as BuffConfigRegisterComponentID} from "components/BuffConfigRegisterComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {ResourceDistributionComponent, ID as ResourceDistributionComponentID} from "components/ResourceDistributionComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

library BuffConfigInitializer {
    function init(IWorld world) internal {
        BuffConfigComponent buffConfig = BuffConfigComponent(
            world.getComponent(BuffConfigComponentID)
        );
        BuffConfigRegisterComponent buffConfigRegister = BuffConfigRegisterComponent(
            world.getComponent(BuffConfigRegisterComponentID)
        );

        BuffConfig[2] memory buffConfigs = [
            BuffConfig({
                buffEffectID: uint256(keccak256("system.BuffEffectAddHPCalculate")),
                asset: "AddHP",
                name: "AddHP",
                buffType: 0,
                continueTime: 86400// 1 day
            }),
            BuffConfig({
                buffEffectID: uint256(keccak256("system.BuffEffectKeepResourceOnDeathExecute")),
                asset: "SecretCoffer",
                name: "SecretCoffer",
                buffType: 1,
                continueTime: 0
            })
        ];

        for (uint i = 0; i < buffConfigs.length; i++) {
            BuffConfig memory config = buffConfigs[i];
            uint256 uid = config.buffEffectID;
            buffConfigRegister.set(uid, SingletonID);
            buffConfig.set(uid, config);
        }
    }
}
