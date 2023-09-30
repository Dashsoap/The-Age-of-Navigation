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
    uint256 constant alphax  = 17139854185464651830997707156806397932210598301068316267714971301178818410963;
    uint256 constant alphay  = 14370275865304035253322027551448035372656951977079919720013946177820952833438;
    uint256 constant betax1  = 21859031408334538559090345825830662428094943830131120430678708374148750232255;
    uint256 constant betax2  = 4523621954533858735465188418685315454718211797765120564090409063226942041621;
    uint256 constant betay1  = 7611163653793814555411690293594012438968309390451100941349530378469244232528;
    uint256 constant betay2  = 19113992957867378381511220130335873989877840539680793978109300474869500156694;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 16291359071944495808198181216042005147380540832973597810957598527128978107983;
    uint256 constant deltax2 = 3343690771494917905871583740165756791010975083865534260200692460575334701702;
    uint256 constant deltay1 = 4367902314126734632505391766324892534356261204804672577782348337436878983271;
    uint256 constant deltay2 = 16579830083713774718053024057532528103302912435493063041413427171795530011306;

    
    uint256 constant IC0x = 17855041649362136394087689952691049654144666885199281026558828458550046456141;
    uint256 constant IC0y = 14168655604854420600593716653694368865711561410849061705060573286991202268742;
    
    uint256 constant IC1x = 6195062156771537314493262603321696088992518753090981737188855978059693315734;
    uint256 constant IC1y = 7035074239416465003930389650619198052176438926073164419596648479920104906549;
    
    uint256 constant IC2x = 6969119071172331587605097588921388748824821390974490718324292512440556244667;
    uint256 constant IC2y = 4451034155805466955932097550857279402106574484260631698083735748631691957082;
    
    uint256 constant IC3x = 15248704199600153990390818045257776329994954500082919241163112430686076132397;
    uint256 constant IC3y = 14641200158400231066311438317714131494771332649874797821671865243850089462893;
    
    uint256 constant IC4x = 9470787117224099188529954970683744499433969851689013150292439578258838570163;
    uint256 constant IC4y = 19306086808431944486675399717422565017381371030107468267285033364526152834504;
    
    uint256 constant IC5x = 7903773040650669568471726245203549344806257268193104986497741604820075178130;
    uint256 constant IC5y = 15044783597215276581526298317549610756419795121785646107154256661553242626260;
    
    uint256 constant IC6x = 13442879051738616781377043306347001319713208094265449802353174560548530898554;
    uint256 constant IC6y = 944798702827607116650428091323448903882755007865690318717805273187581845346;
    
    uint256 constant IC7x = 20512525281233656267939219993195803590764711646042876691396676714743985384227;
    uint256 constant IC7y = 9381675753532876686403956359394768707967881381626673301545239852200614063255;
    
    uint256 constant IC8x = 17242254445956873224681794828178913384651470436003523395943145167186006967234;
    uint256 constant IC8y = 11989827379352298391640788581065494357151304070170087304714275367112934254608;
    
    uint256 constant IC9x = 13262891868437893860306260937267205295848485256018285055884304730319671846645;
    uint256 constant IC9y = 18344794500107051446197406147250388646524294961332527332163770645159053739604;
    
 
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
