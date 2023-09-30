// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {GuildConfigComponent, ID as GuildConfigComponentID, GuildConfig} from "components/GuildConfigComponent.sol";
// import {MoveConfigComponent, ID as MoveConfigComponentID, MoveConfig} from "components/MoveConfigComponent.sol";
// import {VisionConfigComponent, ID as VisionConfigComponentID, VisionConfig} from "components/VisionConfigComponent.sol";
// import {TerrainComponent, ID as TerrainComponentID} from "components/TerrainComponent.sol";
// import {GuildDistributionComponent, ID as GuildDistributionComponentID} from "components/GuildDistributionComponent.sol";
// import {SingletonID} from "solecs/SingletonID.sol";

library GuildConfigInitializer {
    function init(IWorld world) internal {
        GuildConfigComponent guildConfig = GuildConfigComponent(
            world.getComponent(GuildConfigComponentID)
        );
        guildConfig.set(GuildConfig({createCost: 0,
            initTaxRate: 150,// 150/1000
            basicCountLimit: 30,
            initNameForLevel0: "Pending",
            initNameForLevel1: "Member",
            initNameForLevel2: "Manager",
            initNameForLevel3: "Co-President",
            initNameForLevel4: "President",
            basicAreaFactor: 1250,
            basicValueFactor: 2000,
            basicRangeFactor: 1500
        }));
    }
}
