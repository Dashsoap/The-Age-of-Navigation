// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";
import {DevConfigComponent, ID as DevConfigComponentID, DevConfig} from "components/DevConfigComponent.sol";

library VerifyInitializer {
    function init(IWorld world) internal {
        ZKConfigComponent zkConfig = ZKConfigComponent(
            world.getComponent(ZKConfigComponentID)
        );
        // don't set if not checking zk
        zkConfig.set(
            ZKConfig({open: false, initVerifyAddress: 0xd2E3710e75b0BBeF7274EA8C9c912bC8988171F6,
                moveVerifyAddress: 0xDc4c4c2DAC39F2651a54FbCd8d6f7a915e9a3FE0,
                markVerifyAddress: 0xDBb94B1b629dAA61a27d98C745d3D88a0f6d892d,
                treasureVerifyAddress: 0x9eB1f4ce680F57aA78BbD54c05fb641FA138D9C7,
                treasureVerifyv2Address: 0x89e24469AcffbB22DB95e6a3fE2903814FD09075,
                resourceVerifyAddress: 0x4BfFB28b0805Fd57f432CEfD1a649D07c4F43937,
                resourceVerifyv2Address: 0x66EA6D5599D1eDa385BeFBcC08954753D2Eff631,
                attackPathVerifyAddress: 0x5c618759661C342ba99fA59CC05a0Aa7134b7E87,
                coordVerifyAddress: 0x2DB9b64fB4760681Dd5c8A91f37aDAdbAAD7cC9d
            })
        );
        DevConfigComponent(
            world.getComponent(DevConfigComponentID)
        ).set(DevConfig({devMode: true}));
    }
}
