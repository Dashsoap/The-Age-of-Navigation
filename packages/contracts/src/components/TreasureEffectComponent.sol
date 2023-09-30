// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {BareComponent} from "solecs/BareComponent.sol";
import {LibTypes} from "solecs/LibTypes.sol";

uint256 constant ID = uint256(keccak256("component.TreasureEffect"));

struct Effect {
    uint32 valid;
    uint32 triggerType;// 0: airdrop; 1: flightToTarget; 2: flightAndTouch; 3: destroy; 4: passive
    //0: vision; 1: damage; 2: shield; 3: teleprotation;
    // 4: two-way teleprotation; 5: DefenseCannon; 6: Wormhole; 7: LandMine;
    // 8: flightToTarget; 9: fog;
    uint32 effectType;
    uint32 energy;
    uint32 range;
    uint32 area;
    uint32 damage;
    uint32 shield;
}
struct TreasureEffect {
    uint32 isActive;
    uint32 isFlight;
    Effect flight;
    Effect arrival;
    Effect destroy;
    Effect buff;
}

contract TreasureEffectComponent is BareComponent {
    constructor(address world) BareComponent(world, ID) {}

    function getSchema()
        public
        pure
        override
        returns (string[] memory keys, LibTypes.SchemaValue[] memory values)
    {
        keys = new string[](6);
        values = new LibTypes.SchemaValue[](6);

        keys[0] = "isActive";
        values[0] = LibTypes.SchemaValue.UINT32;

        keys[1] = "isFlight";
        values[1] = LibTypes.SchemaValue.UINT32;
        
        keys[2] = "flight";
        values[2] = LibTypes.SchemaValue.UINT32_ARRAY;

        keys[3] = "arrival";
        values[3] = LibTypes.SchemaValue.UINT32_ARRAY;

        keys[4] = "destroy";
        values[4] = LibTypes.SchemaValue.UINT32_ARRAY;

        keys[5] = "buff";
        values[5] = LibTypes.SchemaValue.UINT32_ARRAY;
    }

    function set(
        uint256 entity,
        TreasureEffect memory treasureEffect
    ) public {
        set(entity, abi.encode(treasureEffect.isActive, treasureEffect.isFlight, treasureEffect.flight, treasureEffect.arrival, treasureEffect.destroy, treasureEffect.buff));
    }

    function getValue(
        uint256 entity
    ) public view returns (TreasureEffect memory) {
        (uint32 isActive, uint32 isFlight, Effect memory flight, Effect memory arrival, Effect memory destroy, Effect memory buff) = abi.decode(
            getRawValue(entity),
            (uint32, uint32, Effect, Effect, Effect, Effect)
        );
        return TreasureEffect(isActive, isFlight, flight, arrival, destroy, buff);
    }
}
