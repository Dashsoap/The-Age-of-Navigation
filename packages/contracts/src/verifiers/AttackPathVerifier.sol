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

interface IAttackPathVerifier {
    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[50] calldata _pubSignals) external view returns (bool);
}

contract AttackPathVerifier {
    // Scalar field size
    uint256 constant r    = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    // Base field size
    uint256 constant q   = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    // Verification Key data
    uint256 constant alphax  = 3214934646792539270353249028494845911067490850549768631277598265637422093064;
    uint256 constant alphay  = 4686227449014200625784726111085919162218953343722271171864311744825409991604;
    uint256 constant betax1  = 11382445860631951169189188051575944455100736840956682497749033782582970622253;
    uint256 constant betax2  = 2298059707979965919773634623013647333380389095636913556013430079992639507308;
    uint256 constant betay1  = 8198260914350428098155423691948442565226354598906817364982749462849217964543;
    uint256 constant betay2  = 14271503530370339665111765866607993198435801373660312718543379303662530429341;
    uint256 constant gammax1 = 11559732032986387107991004021392285783925812861821192530917403151452391805634;
    uint256 constant gammax2 = 10857046999023057135944570762232829481370756359578518086990519993285655852781;
    uint256 constant gammay1 = 4082367875863433681332203403145435568316851327593401208105741076214120093531;
    uint256 constant gammay2 = 8495653923123431417604973247489272438418190587263600148770280649306958101930;
    uint256 constant deltax1 = 9239452243901095920845702144061138814668842781974147932240813236376442991081;
    uint256 constant deltax2 = 9566375289269246292861217820598174511216919306311710697185879558023233783001;
    uint256 constant deltay1 = 3171046750420578042834057931921584185784237591882374887900724503800376309244;
    uint256 constant deltay2 = 11677560820784947674704048893125450913183417545793105505002850348855482179145;

    
    uint256 constant IC0x = 14963418985416221542144227333777507459919326154457207827190523812666053113069;
    uint256 constant IC0y = 11451665934843328857352240111411091196651498624532530909990566392393007265088;
    
    uint256 constant IC1x = 20860286409723596883461918339658204581325902450642171382055467076503864226959;
    uint256 constant IC1y = 11906506990416509653497342143622718845354966608743123542930798625374990272332;
    
    uint256 constant IC2x = 1467744305479498730451035310400268522605964777020457588969565998463969376454;
    uint256 constant IC2y = 6557078204756923843859914654565418026565702334218398749238168773034460948073;
    
    uint256 constant IC3x = 19707252500996377038912984130501266221672364712385869682193657439901224166203;
    uint256 constant IC3y = 20660288957685808583857901752989298253889755383401500357794352966168545120648;
    
    uint256 constant IC4x = 20533022307106434882982422335856205481009896522133647000830259057801717251327;
    uint256 constant IC4y = 2743348591891662607330971675693395898738224970128593732481277426681955458158;
    
    uint256 constant IC5x = 15446978776531701063684917275357394798167834723220439197876902290538860425132;
    uint256 constant IC5y = 6244685059801440448001311830212995783695752345758105186719990372021589555154;
    
    uint256 constant IC6x = 1770336588850810872322934133052031201595193728725411658710852697395239232881;
    uint256 constant IC6y = 7264694559966550525474766708535755278477998543056609998605614486553757628581;
    
    uint256 constant IC7x = 20335611272962396827658479243539031312255419094855621287556454288093491973572;
    uint256 constant IC7y = 7165271035922507039451901515229979248473393169291205691927010471979487427332;
    
    uint256 constant IC8x = 18023413694991479273303333897459295187220180604129844962152592353790326975949;
    uint256 constant IC8y = 1219928903360381628631591642845676695877480149040703705319310767597487552627;
    
    uint256 constant IC9x = 20272214978665122578251279283208498917328905595503941070632333949927792460999;
    uint256 constant IC9y = 9663339451032553347834037515304376794865148333594806868101999953033682256911;
    
    uint256 constant IC10x = 1451872016913854012090184814160545529593241592119335743329774741776769248656;
    uint256 constant IC10y = 19727039289159877836657563037091723049370098093687339473250531157295683392804;
    
    uint256 constant IC11x = 12034611674637890891705084210949286219943684650399983943808240396676700296042;
    uint256 constant IC11y = 13054978879813425071099934875501173204257696137883788415062153201414923020952;
    
    uint256 constant IC12x = 21737939102555709968468356832013159645144048043236212356857389551922841323485;
    uint256 constant IC12y = 12013588831172718645792199562814882238247619610916671499364253598844076132231;
    
    uint256 constant IC13x = 7322090520131723919287810931742754178503563157388178839823144357585775431136;
    uint256 constant IC13y = 4256369581984184499349929606141882222549345289141257275970353878730098524586;
    
    uint256 constant IC14x = 8368351262013766266740040789895981387058102053229230228428750621269863347299;
    uint256 constant IC14y = 20579217871678686909799032569223030630022101152831420136306889223079732032262;
    
    uint256 constant IC15x = 18454947514078255279201838298074412370444026181060297659605016929632614185074;
    uint256 constant IC15y = 9905701249595871928610155776418779582289405336177143009080690094853199336745;
    
    uint256 constant IC16x = 19295209875252484474777280058741166223632939525334793935290227302182972118603;
    uint256 constant IC16y = 12814536997152405523515651017009720806326506124128099565659569375181329825978;
    
    uint256 constant IC17x = 13798932272530820336293655612424605975220114920658241827805567039690795698296;
    uint256 constant IC17y = 8331127363210757169237886178294722121882616049546280151391129184704373149323;
    
    uint256 constant IC18x = 11219083034080792221175763640236464216809731268247429230275207466921453337749;
    uint256 constant IC18y = 14637928022525764831941615804896919504113342094204748530837806808056595371292;
    
    uint256 constant IC19x = 16087217303845523307956593802968893741364695615839659879544637804626422469252;
    uint256 constant IC19y = 12614602457925950058779385445168108233000069930819930772464663149079894038828;
    
    uint256 constant IC20x = 18461684776239074978353773286385334743578167645878735937140165891619997611547;
    uint256 constant IC20y = 3371428395908569487318667944848844875805432667353117850972506529483100591615;
    
    uint256 constant IC21x = 10584225140986364805699504976044492268091468595158052569171415831922023950859;
    uint256 constant IC21y = 1219628154242664768660088584275448420106161810181269667606825184203770819961;
    
    uint256 constant IC22x = 4162718717285526370867138771069886063937543006020697363273069342110806219369;
    uint256 constant IC22y = 7008252454723034154646950827102777947695856218716215050549258724304125153651;
    
    uint256 constant IC23x = 16905310406127344654677496189205116003740701019856571276093496809328762806678;
    uint256 constant IC23y = 17500027372714019347373006109150161750246406968131264420009890408669192298251;
    
    uint256 constant IC24x = 3974560648953839708465384740160168610436285495846907838623763395772755545041;
    uint256 constant IC24y = 2620193290457935941744646636465992611250359936222548622869465109303315975715;
    
    uint256 constant IC25x = 17015584226552093212893016184218457039869175006356879098080285881214848664006;
    uint256 constant IC25y = 6427032362241345819755089968018808090958545982907765217238993916111648612971;
    
    uint256 constant IC26x = 12615985152990372059041931410764314206284612907498021418890009864249614244006;
    uint256 constant IC26y = 16713812760086507201236836401710877261171191485108237257388774246122418975816;
    
    uint256 constant IC27x = 9105314535323751478757777779237535632987299492146786509516891157720947775963;
    uint256 constant IC27y = 19738319388220610789037875010539857408173681635478489961682174263752827948841;
    
    uint256 constant IC28x = 16276884491919541619033654759559909746728316175965823902247257727908370628011;
    uint256 constant IC28y = 10835561260577366731370357057398939080499542184397869548904359825366629212813;
    
    uint256 constant IC29x = 3907951204597444414276742064132332300103417536751602798030421505385664536778;
    uint256 constant IC29y = 12702372961557636778054897583930329379180155747513890723449692616766898851006;
    
    uint256 constant IC30x = 20947141866169777064623084679652487784000052602947025390845243182929638187436;
    uint256 constant IC30y = 14735172539152145583759308984291118620164578189082970747090573960867043040359;
    
    uint256 constant IC31x = 19948179391206115788906489235043226031248580361960113733789771097560652225664;
    uint256 constant IC31y = 12362071356490660339627874912739650791228267043068474823287140865755441424698;
    
    uint256 constant IC32x = 14419971611249150232218234213709346338701216955252613297381792234907771111197;
    uint256 constant IC32y = 16399723519219511823690640135080516620168208005440217274357543844719349486712;
    
    uint256 constant IC33x = 2404696840758646698595895904247371633633177235096241420624300883041164150396;
    uint256 constant IC33y = 1966171298179333640798606416689365985675254571159880247341863401177501085777;
    
    uint256 constant IC34x = 8618558645028216054980618172890718160887513176453862089698886148459829856773;
    uint256 constant IC34y = 19145505611192678544428599958191122066229940842216195628784611287109256979913;
    
    uint256 constant IC35x = 18284249158666939446927075909160987114013848482492692974786661136541370261079;
    uint256 constant IC35y = 6547289681524112018528540725945624791745604113843911477089986497109237477289;
    
    uint256 constant IC36x = 16726195878283719645087687867985071551980284054334998655576335498546926910069;
    uint256 constant IC36y = 6319524962042067341707737675216425167526266714489557156365679084247057601803;
    
    uint256 constant IC37x = 5588154185172002070648207070996453043313583679884175205991711684601449550855;
    uint256 constant IC37y = 2951220254795855597030648249507656374249470024477912765892636876301538240777;
    
    uint256 constant IC38x = 387339649526641805188704745641359768512027150892480026063797193144756249213;
    uint256 constant IC38y = 18733652411853328109217261163686823456648377293896446058991573962848532623926;
    
    uint256 constant IC39x = 9526800408626094391764673085613638048686165238333599310018272769748584163117;
    uint256 constant IC39y = 8262657391526521815069387132748885089840804846618071832579591415029145848304;
    
    uint256 constant IC40x = 12051384239658840368187785646497925332428031706375260189599611288919584386014;
    uint256 constant IC40y = 21682754966539094888165410815532758096664431651078826619502387756141482464714;
    
    uint256 constant IC41x = 13899151878980933597030326867747089420038128791341612594286106848483430411576;
    uint256 constant IC41y = 8051823618617151251858986759216132584243805013623807770853905091711344718661;
    
    uint256 constant IC42x = 4546658480283167184060411007235963895313210774256224901483780753843904074964;
    uint256 constant IC42y = 14312161125127895941582012480116378998759803522974185303895949376313441847875;
    
    uint256 constant IC43x = 11245666577336515182460431700246618210094789895147611918794291635877816413272;
    uint256 constant IC43y = 17296850528309024051550681856007954041465547056255939972151313819168922568260;
    
    uint256 constant IC44x = 2124393273337470728460839986631750237768191636739412076436658566998462257797;
    uint256 constant IC44y = 13418525987274766136470898793955557587140613332679518930893617007518630964097;
    
    uint256 constant IC45x = 16920892319140891319099176976311216325748122286182199930536825309847480250076;
    uint256 constant IC45y = 13462442104275757129587642310397829559099960724098189751217278809430099369964;
    
    uint256 constant IC46x = 21339079489020625776983502118032900803291088900471133814801252831066412106531;
    uint256 constant IC46y = 15758849094649862523269312911826335147064809217075012859092300792336385473803;
    
    uint256 constant IC47x = 1231366883481069630859618056616334217463384456645302666898935378787917926599;
    uint256 constant IC47y = 20072339067432274237138974354239356853505666331424997946910444917253348907884;
    
    uint256 constant IC48x = 16885762904152290525842640580417531604880375867696126820173569404495686291218;
    uint256 constant IC48y = 12785949583517299560646530825119867612881421976629055351800624300046127326485;
    
    uint256 constant IC49x = 16371190253451373033354778540887460208922796438992901409657426441601885026958;
    uint256 constant IC49y = 21705201210652136268376362789891427151535804490381063487913666476764685251310;
    
    uint256 constant IC50x = 13037422803693658562040326259662340846344881155237898753959778989032676377261;
    uint256 constant IC50y = 12761570600823986640459645600187148367093044463229737036372754845394384486842;
    
 
    // Memory data
    uint16 constant pVk = 0;
    uint16 constant pPairing = 128;

    uint16 constant pLastMem = 896;

    function verifyProof(uint[2] calldata _pA, uint[2][2] calldata _pB, uint[2] calldata _pC, uint[50] calldata _pubSignals) public view returns (bool) {
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
                
                g1_mulAccC(_pVk, IC10x, IC10y, calldataload(add(pubSignals, 288)))
                
                g1_mulAccC(_pVk, IC11x, IC11y, calldataload(add(pubSignals, 320)))
                
                g1_mulAccC(_pVk, IC12x, IC12y, calldataload(add(pubSignals, 352)))
                
                g1_mulAccC(_pVk, IC13x, IC13y, calldataload(add(pubSignals, 384)))
                
                g1_mulAccC(_pVk, IC14x, IC14y, calldataload(add(pubSignals, 416)))
                
                g1_mulAccC(_pVk, IC15x, IC15y, calldataload(add(pubSignals, 448)))
                
                g1_mulAccC(_pVk, IC16x, IC16y, calldataload(add(pubSignals, 480)))
                
                g1_mulAccC(_pVk, IC17x, IC17y, calldataload(add(pubSignals, 512)))
                
                g1_mulAccC(_pVk, IC18x, IC18y, calldataload(add(pubSignals, 544)))
                
                g1_mulAccC(_pVk, IC19x, IC19y, calldataload(add(pubSignals, 576)))
                
                g1_mulAccC(_pVk, IC20x, IC20y, calldataload(add(pubSignals, 608)))
                
                g1_mulAccC(_pVk, IC21x, IC21y, calldataload(add(pubSignals, 640)))
                
                g1_mulAccC(_pVk, IC22x, IC22y, calldataload(add(pubSignals, 672)))
                
                g1_mulAccC(_pVk, IC23x, IC23y, calldataload(add(pubSignals, 704)))
                
                g1_mulAccC(_pVk, IC24x, IC24y, calldataload(add(pubSignals, 736)))
                
                g1_mulAccC(_pVk, IC25x, IC25y, calldataload(add(pubSignals, 768)))
                
                g1_mulAccC(_pVk, IC26x, IC26y, calldataload(add(pubSignals, 800)))
                
                g1_mulAccC(_pVk, IC27x, IC27y, calldataload(add(pubSignals, 832)))
                
                g1_mulAccC(_pVk, IC28x, IC28y, calldataload(add(pubSignals, 864)))
                
                g1_mulAccC(_pVk, IC29x, IC29y, calldataload(add(pubSignals, 896)))
                
                g1_mulAccC(_pVk, IC30x, IC30y, calldataload(add(pubSignals, 928)))
                
                g1_mulAccC(_pVk, IC31x, IC31y, calldataload(add(pubSignals, 960)))
                
                g1_mulAccC(_pVk, IC32x, IC32y, calldataload(add(pubSignals, 992)))
                
                g1_mulAccC(_pVk, IC33x, IC33y, calldataload(add(pubSignals, 1024)))
                
                g1_mulAccC(_pVk, IC34x, IC34y, calldataload(add(pubSignals, 1056)))
                
                g1_mulAccC(_pVk, IC35x, IC35y, calldataload(add(pubSignals, 1088)))
                
                g1_mulAccC(_pVk, IC36x, IC36y, calldataload(add(pubSignals, 1120)))
                
                g1_mulAccC(_pVk, IC37x, IC37y, calldataload(add(pubSignals, 1152)))
                
                g1_mulAccC(_pVk, IC38x, IC38y, calldataload(add(pubSignals, 1184)))
                
                g1_mulAccC(_pVk, IC39x, IC39y, calldataload(add(pubSignals, 1216)))
                
                g1_mulAccC(_pVk, IC40x, IC40y, calldataload(add(pubSignals, 1248)))
                
                g1_mulAccC(_pVk, IC41x, IC41y, calldataload(add(pubSignals, 1280)))
                
                g1_mulAccC(_pVk, IC42x, IC42y, calldataload(add(pubSignals, 1312)))
                
                g1_mulAccC(_pVk, IC43x, IC43y, calldataload(add(pubSignals, 1344)))
                
                g1_mulAccC(_pVk, IC44x, IC44y, calldataload(add(pubSignals, 1376)))
                
                g1_mulAccC(_pVk, IC45x, IC45y, calldataload(add(pubSignals, 1408)))
                
                g1_mulAccC(_pVk, IC46x, IC46y, calldataload(add(pubSignals, 1440)))
                
                g1_mulAccC(_pVk, IC47x, IC47y, calldataload(add(pubSignals, 1472)))
                
                g1_mulAccC(_pVk, IC48x, IC48y, calldataload(add(pubSignals, 1504)))
                
                g1_mulAccC(_pVk, IC49x, IC49y, calldataload(add(pubSignals, 1536)))
                
                g1_mulAccC(_pVk, IC50x, IC50y, calldataload(add(pubSignals, 1568)))
                

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
            
            checkField(calldataload(add(_pubSignals, 320)))
            
            checkField(calldataload(add(_pubSignals, 352)))
            
            checkField(calldataload(add(_pubSignals, 384)))
            
            checkField(calldataload(add(_pubSignals, 416)))
            
            checkField(calldataload(add(_pubSignals, 448)))
            
            checkField(calldataload(add(_pubSignals, 480)))
            
            checkField(calldataload(add(_pubSignals, 512)))
            
            checkField(calldataload(add(_pubSignals, 544)))
            
            checkField(calldataload(add(_pubSignals, 576)))
            
            checkField(calldataload(add(_pubSignals, 608)))
            
            checkField(calldataload(add(_pubSignals, 640)))
            
            checkField(calldataload(add(_pubSignals, 672)))
            
            checkField(calldataload(add(_pubSignals, 704)))
            
            checkField(calldataload(add(_pubSignals, 736)))
            
            checkField(calldataload(add(_pubSignals, 768)))
            
            checkField(calldataload(add(_pubSignals, 800)))
            
            checkField(calldataload(add(_pubSignals, 832)))
            
            checkField(calldataload(add(_pubSignals, 864)))
            
            checkField(calldataload(add(_pubSignals, 896)))
            
            checkField(calldataload(add(_pubSignals, 928)))
            
            checkField(calldataload(add(_pubSignals, 960)))
            
            checkField(calldataload(add(_pubSignals, 992)))
            
            checkField(calldataload(add(_pubSignals, 1024)))
            
            checkField(calldataload(add(_pubSignals, 1056)))
            
            checkField(calldataload(add(_pubSignals, 1088)))
            
            checkField(calldataload(add(_pubSignals, 1120)))
            
            checkField(calldataload(add(_pubSignals, 1152)))
            
            checkField(calldataload(add(_pubSignals, 1184)))
            
            checkField(calldataload(add(_pubSignals, 1216)))
            
            checkField(calldataload(add(_pubSignals, 1248)))
            
            checkField(calldataload(add(_pubSignals, 1280)))
            
            checkField(calldataload(add(_pubSignals, 1312)))
            
            checkField(calldataload(add(_pubSignals, 1344)))
            
            checkField(calldataload(add(_pubSignals, 1376)))
            
            checkField(calldataload(add(_pubSignals, 1408)))
            
            checkField(calldataload(add(_pubSignals, 1440)))
            
            checkField(calldataload(add(_pubSignals, 1472)))
            
            checkField(calldataload(add(_pubSignals, 1504)))
            
            checkField(calldataload(add(_pubSignals, 1536)))
            
            checkField(calldataload(add(_pubSignals, 1568)))
            
            checkField(calldataload(add(_pubSignals, 1600)))
            

            // Validate all evaluations
            let isValid := checkPairing(_pA, _pB, _pC, _pubSignals, pMem)

            mstore(0, isValid)
             return(0, 0x20)
         }
     }
 }
