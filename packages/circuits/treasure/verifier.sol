// SPDX-License-Identifier: GPL-3.0
/*
    Copyright 2021 0KIMS association.

    This file is generated with [snarkJS](https://github.com/iden3/snarkjs).

    snarkJS is a free software: you can redistribute it and/or modify it
    under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    snarkJS is distributed in the hope that it will be useful, but WITHOUT
    ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
    or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public
    License for more details.

    You should have received a copy of the GNU General Public License
    along with snarkJS. If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity >=0.7.0 <0.9.0;

contract Groth16Verifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 10194117846937976331961731531334136170455933787736226278818352131241857819781;
    uint256 constant alphay  = 18132515232647809588929382326666697447797282742280434709613705311923975527324;
    uint256 constant betax1  = 13056446818078648797082869074637174233355609750359766296493771142710612185958;
    uint256 constant betax2  = 1730230468730203194181551770387965528877746343283899730031062390745528668804;
    uint256 constant betay1  = 9241218321288264428481305772796959039278400595523062211715407089718932665890;
    uint256 constant betay2  = 15515753572297259697725908060269955503277838944574995582520508639918766885872;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 20474061487071620060766094702797489477083088624634008626727719058160792854853;
    uint256 constant deltax2 = 21660450318698736764798606809688155357465781319910711048088395226037095135220;
    uint256 constant deltay1 = 629187336764829462116792790475374940012080986572307771222219782643460476985;
    uint256 constant deltay2 = 569487160079693070629140916619851474883020263037563226464068852419355119568;

    
    uint256 constant IC0x = 20813394919562813890501884922013597608458709478138977920695534596025346488332;
    uint256 constant IC0y = 11572097570404888534817815964806030640408582245995076714689705940156480246559;
    
    uint256 constant IC1x = 12483299144618661498250881447185293749559050456854844407533300217835878474177;
    uint256 constant IC1y = 16000064186931751012978591889091892669427057976693912869320776588505074630964;
    
    uint256 constant IC2x = 1445090122021315498235415463187657161704812626320835559494797081965392215445;
    uint256 constant IC2y = 6918715644316951056135719332443510636020482421746478513822154368045215793575;
    
    uint256 constant IC3x = 11795329262634584907322144856724628846288332867375136446676408157471381248275;
    uint256 constant IC3y = 724837404759375365235844525756698011182971755485108713787845110621400406090;
    
    uint256 constant IC4x = 15151626008376884334992007564158973906482718788692851592489804672430971883258;
    uint256 constant IC4y = 10834838900511009262733787617221663943867849672590608465483876443199338729495;
    
    uint256 constant IC5x = 10318307457853119084296015226259534533082125084458992819650187348191937956689;
    uint256 constant IC5y = 17503312501135360261295539148147890042733244323751374705793497010683246313625;
    
    uint256 constant IC6x = 18888478366759256793482681695210825531501729131790502119584539764842208793307;
    uint256 constant IC6y = 18773432708791730335142639295248326738582168838700365409982550206660575775715;
    
    uint256 constant IC7x = 8348526265972051525013015094426881387887721719948699974214503054770130236742;
    uint256 constant IC7y = 15998903731179389118965212797382951185397684505898426941547826697919269160435;
    
    uint256 constant IC8x = 10842905848804925270195657498417737861961761875615855615917529046760936376380;
    uint256 constant IC8y = 17924612014096640583934548320963124685096243805992580264629108151039033400079;
    
    uint256 constant IC9x = 2376216047089818254344825926149076423330763343349875594900681949303527235797;
    uint256 constant IC9y = 17400261932280404937550157292275574194585541472457985488809598259232976564462;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[9] calldata _pubSignals) public view returns (bool) {
        assembly {
            function checkField(v) {
                if iszero(lt(v, q)) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }
            
            // G1 function to multiply a G1 value(x,y) to value in an address
            function g1_mulAccC(pR, x, y, s) {
                let success
                let mIn := mload(0x40)
                mstore(mIn, x)
                mstore(add(mIn, 32), y)
                mstore(add(mIn, 64), s)

                success := staticcall(sub(gas(), 2000), 7, mIn, 96, mIn, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }

                mstore(add(mIn, 64), mload(pR))
                mstore(add(mIn, 96), mload(add(pR, 32)))

                success := staticcall(sub(gas(), 2000), 6, mIn, 128, pR, 64)

                if iszero(success) {
                    mstore(0, 0)
                    return(0, 0x20)
                }
            }

            function checkPairing(pA, pB, pC, pubSignals, pMem) -> isOk {
                let _pPairing := add(pMem, pPairing)
                let _pVk := add(pMem, pVk)

                mstore(_pVk, IC0x)
                mstore(add(_pVk, 32), IC0y)

                // Compute the linear combination vk_x
                
                g1_mulAccC(_pVk, IC1x, IC1y, calldataload(add(pubSignals, 0)))
                
                g1_mulAccC(_pVk, IC2x, IC2y, calldataload(add(pubSignals, 32)))
                
                g1_mulAccC(_pVk, IC3x, IC3y, calldataload(add(pubSignals, 64)))
                
                g1_mulAccC(_pVk, IC4x, IC4y, calldataload(add(pubSignals, 96)))
                
                g1_mulAccC(_pVk, IC5x, IC5y, calldataload(add(pubSignals, 128)))
                
                g1_mulAccC(_pVk, IC6x, IC6y, calldataload(add(pubSignals, 160)))
                
                g1_mulAccC(_pVk, IC7x, IC7y, calldataload(add(pubSignals, 192)))
                
                g1_mulAccC(_pVk, IC8x, IC8y, calldataload(add(pubSignals, 224)))
                
                g1_mulAccC(_pVk, IC9x, IC9y, calldataload(add(pubSignals, 256)))
                

                // -A
                mstore(_pPairing, calldataload(pA))
                mstore(add(_pPairing, 32), mod(sub(q, calldataload(add(pA, 32))), q))

                // B
                mstore(add(_pPairing, 64), calldataload(pB))
                mstore(add(_pPairing, 96), calldataload(add(pB, 32)))
                mstore(add(_pPairing, 128), calldataload(add(pB, 64)))
                mstore(add(_pPairing, 160), calldataload(add(pB, 96)))

                // alpha1
                mstore(add(_pPairing, 192), alphax)
                mstore(add(_pPairing, 224), alphay)

                // beta2
                mstore(add(_pPairing, 256), betax1)
                mstore(add(_pPairing, 288), betax2)
                mstore(add(_pPairing, 320), betay1)
                mstore(add(_pPairing, 352), betay2)

                // vk_x
                mstore(add(_pPairing, 384), mload(add(pMem, pVk)))
                mstore(add(_pPairing, 416), mload(add(pMem, add(pVk, 32))))


                // gamma2
                mstore(add(_pPairing, 448), gammax1)
                mstore(add(_pPairing, 480), gammax2)
                mstore(add(_pPairing, 512), gammay1)
                mstore(add(_pPairing, 544), gammay2)

                // C
                mstore(add(_pPairing, 576), calldataload(pC))
                mstore(add(_pPairing, 608), calldataload(add(pC, 32)))

                // delta2
                mstore(add(_pPairing, 640), deltax1)
                mstore(add(_pPairing, 672), deltax2)
                mstore(add(_pPairing, 704), deltay1)
                mstore(add(_pPairing, 736), deltay2)


                let success := staticcall(sub(gas(), 2000), 8, _pPairing, 768, _pPairing, 0x20)

                isOk := and(success, mload(_pPairing))
            }

            let pMem := mload(0x40)
            mstore(0x40, add(pMem, pLastMem))

            // Validate that all evaluations ∈ F
            
            checkField(calldataload(add(_pubSignals, 0)))
            
            checkField(calldataload(add(_pubSignals, 32)))
            
            checkField(calldataload(add(_pubSignals, 64)))
            
            checkField(calldataload(add(_pubSignals, 96)))
            
            checkField(calldataload(add(_pubSignals, 128)))
            
            checkField(calldataload(add(_pubSignals, 160)))
            
            checkField(calldataload(add(_pubSignals, 192)))
            
            checkField(calldataload(add(_pubSignals, 224)))
            
            checkField(calldataload(add(_pubSignals, 256)))
            
            checkField(calldataload(add(_pubSignals, 288)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
