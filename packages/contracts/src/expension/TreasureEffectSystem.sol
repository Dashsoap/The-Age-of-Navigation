// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import {System, IWorld} from "solecs/System.sol";
import {IUint256Component} from "solecs/interfaces/IUint256Component.sol";
import {ZKConfigComponent, ID as ZKConfigComponentID, ZKConfig} from "components/ZKConfigComponent.sol";
import {MapConfigv2Component, ID as MapConfigv2ComponentID, MapConfig} from "components/MapConfigv2Component.sol";
import {ICoordVerifier} from "verifiers/CoordVerifier.sol";
import {getAddressById} from "solecs/utils.sol";

struct CoordVerifyParam {
    uint256 realHash;
    uint256 fogHash;
    uint256 fogSeed;
    uint256 width;
    uint256 height;
    uint256[2] a;
    uint256[2][2] b;
    uint256[2] c;
}

struct TreasureEffectInfo {
    uint256 sourceID;
    bool isComponent;
    uint256 entity;
    uint256 treasureID;
    CoordVerifyParam[] path;
    CoordVerifyParam[] area;
    uint32 areaAmount;
    uint32 value;
}

function checkCoordZK(CoordVerifyParam memory coord, IUint256Component components) view returns (bool) {
    ZKConfig memory zkConfig = ZKConfigComponent(
        getAddressById(components, ZKConfigComponentID)
    ).getValue();
    if (zkConfig.open) {
        uint256[5] memory input = [coord.realHash, coord.fogHash, coord.fogSeed, coord.width, coord.height];
        return ICoordVerifier(zkConfig.coordVerifyAddress).verifyProof(
            coord.a,
            coord.b,
            coord.c,
            input
        );
    }
    MapConfig memory mapConfig = MapConfigv2Component(
        getAddressById(components, MapConfigv2ComponentID)
    ).getValue();
    require(
        coord.width <= mapConfig.gameRadiusX &&
            coord.height <= mapConfig.gameRadiusY,
        "radius over limit"
    );
}

interface ITreasureEffectSystem {
    function execute(bytes memory args) external returns (bytes memory);

    function executeTyped(TreasureEffectInfo memory effectInfo) external returns (bytes memory);
}

abstract contract TreasureEffectSystem is System {
    constructor(
        IWorld _world,
        address _components
    ) System(_world, _components) {}

    function execute(bytes memory args) public returns (bytes memory) {
        TreasureEffectInfo memory effectInfo = abi.decode(args, (TreasureEffectInfo));
        return executeTyped(effectInfo);
    }

    function executeTyped(
        TreasureEffectInfo memory effectInfo
    ) public returns (bytes memory) {
        return effectLogic(effectInfo);
    }

    function effectLogic(TreasureEffectInfo memory effectInfo) virtual internal returns (bytes memory) {}
}
