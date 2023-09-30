// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {IWorld} from "solecs/interfaces/IWorld.sol";
import {TriggerSystemsComponent, ID as TriggerSystemsComponentID} from "components/TriggerSystemsComponent.sol";
import {TriggerSetComponentsComponent, ID as TriggerSetComponentsComponentID} from "components/TriggerSetComponentsComponent.sol";
import {TriggerRemoveComponentsComponent, ID as TriggerRemoveComponentsComponentID} from "components/TriggerRemoveComponentsComponent.sol";
import {SingletonID} from "solecs/SingletonID.sol";

struct SetPair {
    uint256 setComponentID;
    uint256 systemID;
}
struct RemovePair {
    uint256 removeComponentID;
    uint256 systemID;
}

library TriggerConfigInitializer {
    function init(IWorld world) internal {
        TriggerSystemsComponent systems = TriggerSystemsComponent(
            world.getComponent(TriggerSystemsComponentID)
        );
        TriggerSetComponentsComponent setComponents = TriggerSetComponentsComponent(
            world.getComponent(TriggerSetComponentsComponentID)
        );
        TriggerRemoveComponentsComponent removeComponents = TriggerRemoveComponentsComponent(
            world.getComponent(TriggerRemoveComponentsComponentID)
        );

        // SetPair[2] memory setPairs = [
        //     SetPair({
        //         setComponentID: "",
        //         systemID: ""
        //     }),
        //     SetPair({
        //         setComponentID: "",
        //         systemID: ""
        //     })
        // ];

        // for (uint i = 0; i < setPairs.length; i++) {
        //     SetPair memory pair = setPairs[i];
        //     uint256 uid = world.getUniqueEntityId();
        //     setComponents.set(uid, pair.setComponentID);
        //     systems.set(uid, pair.systemID);
        // }

        RemovePair[1] memory removePairs = [
            RemovePair({removeComponentID: uint256(keccak256("component.HP")), systemID: uint256(keccak256("system.DeathTrigger"))
            })
        ];

        for (uint i = 0; i < removePairs.length; i++) {
            RemovePair memory pair = removePairs[i];
            uint256 uid = world.getUniqueEntityId();
            removeComponents.set(uid, pair.removeComponentID);
            systems.set(uid, pair.systemID);
        }
    }
}
