import time

from web3 import Web3
from script.systems.System import System
from script.testSystem import Actors

class TreasureSystem(System):
    def __init__(self) -> None:
        self.name = "TreasureSystem"
        self.components = [
            "Treasurev2",
            "GoldAmount",
            "PlayerBelonging",
            "TreasureAirdropCharging",
            "TreasureLinearCharging",
            "TreasureBounded",
            "TreasureBuildConfig",
            "TreasureConfig",
            "TreasureDistribution",
            "TreasureEffectv2",
            "TreasureEffectConfig",
            "TreasureEffectConfigRegister",
            "TreasureEffectGenerateConfig",
            "TreasureEffectGlobalConfig",
            "TreasurePicked",
            "TreasureTimer",
            "BuffBelonging",
        ]
        self.systems = [
            "PickUpTreasurev2",
            "BuildTreasure",
            "BoundTreasure",
            "UnboundTreasure",
            "ChargeAirdropTreasure",
            "ChargeLinearTreasure",
            "ReleaseAirdropTreasure",
            "ReleaseLinearTreasure",
            "TreasureEffectAirdropDefense",
            "TreasureEffectAirdropResource",
            "TreasureEffectDeathKeepResource",
            "TreasureEffectLinearDamage",
            "TreasureEffectNegativeAddHP",
        ]
        self.system_input = {
            "PickUpTreasurev2": {
                "formatter": "({realHash},{fogHash},{width},{height},{terrainSeed},{fogSeed},{treasureSeed},{terrainPerlin},{treasurePerlin},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}])",
                "params": [
                    "{realHash}",
                    "{fogHash}",
                    "{width}",
                    "{height}",
                    "{terrainSeed}",
                    "{fogSeed}",
                    "{treasureSeed}",
                    "{terrainPerlin}",
                    "{treasurePerlin}",
                    "{a[0]}",
                    "{a[1]}",
                    "{b[0][0]}",
                    "{b[0][1]}",
                    "{b[1][0]}",
                    "{b[1][1]}",
                    "{c[0]}",
                    "{c[1]}",
                ]
            },
            "BuildTreasure": {
                "formatter": "({amount},{salt})",
                "params": [
                    "{amount}",
                    "{salt}",
                ]
            },
            "ChargeAirDropTreasure": {
                "formatter": "({treasureId},({positionRealHash},{positionFogHash},{positionFogSeed},{positionWidth},{positionHeight},[{positionA[0]},{positionA[1]}],[[{positionB[0][0]},{positionB[0][1]}],[{positionB[1][0]},{positionB[1][1]}]],[{positionC[0]},{positionC[1]}]),({targetRealHash},{targetFogHash},{targetFogSeed},{targetWidth},{targetHeight},[{targetA[0]},{targetA[1]}],[[{targetB[0][0]},{targetB[0][1]}],[{targetB[1][0]},{targetB[1][1]}]],[{targetC[0]},{targetC[1]}]),{area})",
                "params": [
                    "{treasureId}",
                    "{positionRealHash}",
                    "{positionFogHash}",
                    "{positionFogSeed}",
                    "{positionWidth}",
                    "{positionHeight}",
                    "{positionA[0]}",
                    "{positionA[1]}",
                    "{positionB[0][0]}",
                    "{positionB[0][1]}",
                    "{positionB[1][0]}",
                    "{positionB[1][1]}",
                    "{positionC[0]}",
                    "{positionC[1]}",
                    "{targetRealHash}",
                    "{targetFogHash}",
                    "{targetFogSeed}",
                    "{targetWidth}",
                    "{targetHeight}",
                    "{targetA[0]}",
                    "{targetA[1]}",
                    "{targetB[0][0]}",
                    "{targetB[0][1]}",
                    "{targetB[1][0]}",
                    "{targetB[1][1]}",
                    "{targetC[0]}",
                    "{targetC[1]}",
                    "{area}",
                ]
            },
            "ChargeLinearTreasure": {
                "formatter": "({treasureId},({positionRealHash},{positionFogHash},{positionFogSeed},{positionWidth},{positionHeight},[{positionA[0]},{positionA[1]}],[[{positionB[0][0]},{positionB[0][1]}],[{positionB[1][0]},{positionB[1][1]}]],[{positionC[0]},{positionC[1]}]),{direction},{distance},{area})",
                "params": [
                    "{treasureId}",
                    "{positionRealHash}",
                    "{positionFogHash}",
                    "{positionFogSeed}",
                    "{positionWidth}",
                    "{positionHeight}",
                    "{positionA[0]}",
                    "{positionA[1]}",
                    "{positionB[0][0]}",
                    "{positionB[0][1]}",
                    "{positionB[1][0]}",
                    "{positionB[1][1]}",
                    "{positionC[0]}",
                    "{positionC[1]}",
                    "{direction}",
                    "{distance}",
                    "{area}",
                ]
            },
            "ReleaseAirDropTreasure": {
                "formatter": "({treasureId},[({pathRealHash},{pathFogHash},{pathFogSeed},{pathWidth},{pathHeight},[{pathA[0]},{pathA[1]}],[[{pathB[0][0]},{pathB[0][1]}],[{pathB[1][0]},{pathB[1][1]}]],[{pathC[0]},{pathC[1]}])],[({areaRealHash},{areaFogHash},{areaFogSeed},{areaWidth},{areaHeight},[{areaA[0]},{areaA[1]}],[[{areaB[0][0]},{areaB[0][1]}],[{areaB[1][0]},{areaB[1][1]}]],[{areaC[0]},{areaC[1]}])])",
                "params": [
                    "{treasureId}",
                    "{pathRealHash}",
                    "{pathFogHash}",
                    "{pathFogSeed}",
                    "{pathWidth}",
                    "{pathHeight}",
                    "{pathA[0]}",
                    "{pathA[1]}",
                    "{pathB[0][0]}",
                    "{pathB[0][1]}",
                    "{pathB[1][0]}",
                    "{pathB[1][1]}",
                    "{pathC[0]}",
                    "{pathC[1]}",
                    "{areaRealHash}",
                    "{areaFogHash}",
                    "{areaFogSeed}",
                    "{areaWidth}",
                    "{areaHeight}",
                    "{areaA[0]}",
                    "{areaA[1]}",
                    "{areaB[0][0]}",
                    "{areaB[0][1]}",
                    "{areaB[1][0]}",
                    "{areaB[1][1]}",
                    "{areaC[0]}",
                    "{areaC[1]}",
                ]
            },
            "ReleaseLinearTreasure": {
                "formatter": "({treasureId},[({pathRealHash},{pathFogHash},{pathFogSeed},{pathWidth},{pathHeight},[{pathA[0]},{pathA[1]}],[[{pathB[0][0]},{pathB[0][1]}],[{pathB[1][0]},{pathB[1][1]}]],[{pathC[0]},{pathC[1]}])],[({areaRealHash},{areaFogHash},{areaFogSeed},{areaWidth},{areaHeight},[{areaA[0]},{areaA[1]}],[[{areaB[0][0]},{areaB[0][1]}],[{areaB[1][0]},{areaB[1][1]}]],[{areaC[0]},{areaC[1]}])])",
                "params": [
                    "{treasureId}",
                    "{pathRealHash}",
                    "{pathFogHash}",
                    "{pathFogSeed}",
                    "{pathWidth}",
                    "{pathHeight}",
                    "{pathA[0]}",
                    "{pathA[1]}",
                    "{pathB[0][0]}",
                    "{pathB[0][1]}",
                    "{pathB[1][0]}",
                    "{pathB[1][1]}",
                    "{pathC[0]}",
                    "{pathC[1]}",
                    "{areaRealHash}",
                    "{areaFogHash}",
                    "{areaFogSeed}",
                    "{areaWidth}",
                    "{areaHeight}",
                    "{areaA[0]}",
                    "{areaA[1]}",
                    "{areaB[0][0]}",
                    "{areaB[0][1]}",
                    "{areaB[1][0]}",
                    "{areaB[1][1]}",
                    "{areaC[0]}",
                    "{areaC[1]}",
                ]
            },
            "BoundTreasure": {
                "formatter": "{treasureId}",
                "params": ["{treasureId}"]
            },
            "UnboundTreasure": {
                "formatter": "{treasureId}",
                "params": ["{treasureId}"]
            },
        }
    
    def build_treasure(self, actors: Actors):
        basic_actor = actors.actors[0]
        # build treasure
        ori_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
        self.log("before build")
        self.log(ori_treasures)
        self.log("building treasure")
        import random
        result = basic_actor.send("BuildTreasure", f"(200,{random.randint(0, 999999)})")
        self.log(result['hash'])
        new_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
        self.log("after build")
        self.log(new_treasures)
        treasure_id = 0
        for treasure in new_treasures:
            if treasure not in ori_treasures:
                treasure_id = treasure
                break
        if treasure_id:
            self.log("build success")
            return (treasure_id, True)
        return (0, False)

    def execute_test(self, actors: Actors):
        basic_actor = actors.actors[0]
        # pick up hp
        ori_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
        self.log("before pickUp")
        self.log(ori_treasures)
        self.log("picking up")
        result = basic_actor.send("PickUpTreasurev2", "(1760186212227967992807915426465403124144027458072790513337346726966364932656,6548174236596742820902339565391718630727264115530773170571288163083533194409,50,100,11111,44444,33333,8644,6238,[11538206455640720466640711837297826683524684026372983429946026872045322593968,3084973448710277781308357174201635783464759063868187868846563219816703168192],[[14930027661629835727156696525743391942085658614536307097864369254869629065885,4978354910553624343434497404777764576121103454186573889821712895202387407651],[11372744352038246689165463543868659985949902532892695778413523550830778076365,15653173690173926315317188297896327927110188042191661565608910270552655942006]],[4024965682387492577492880537172505462923827106192464161576239102164553296249,1620629137920086813252406903747754300169890588272636513513267757496838294316])")
        self.log(result['hash'])
        new_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
        self.log("after pickUp")
        self.log(new_treasures)
        treasure_id = 0
        for treasure in new_treasures:
            if treasure not in ori_treasures:
                treasure_id = treasure
                break
        if treasure_id:
            self.log("pick up success")
            treasure = basic_actor.getValue("Treasurev2", f"{treasure_id}")
            self.log("treasure after pickUp")
            self.log(treasure)
            treasure_effect = basic_actor.getValue("TreasureEffectv2", f"{treasure_id}")
            self.log("treasure effect after pickUp")
            self.log(treasure_effect)
            config_id = treasure_effect[0]
            config = basic_actor.getValue("TreasureEffectConfig", f"{config_id}")
            self.log("treasure effect config after pickUp")
            self.log(config)
            treasure_timer = basic_actor.getValue("TreasureTimer", f"{treasure_id}")
            self.log("treasure timer after pickUp")
            self.log(treasure_timer)
            ori_buffs = basic_actor.getEntitiesWithValue("BuffBelonging", f"{basic_actor.player}")
            self.log("buffs before bound treasure")
            self.log(ori_buffs)
            self.log("bounding treasure")
            result = basic_actor.send("BoundTreasure", f"{treasure_id}")
            self.log(result['hash'])
            treasure_bounded = basic_actor.has("TreasureBounded", f"{treasure_id}")
            self.log("treasureBounded.has")
            self.log(treasure_bounded)
            new_buffs = basic_actor.getEntitiesWithValue("BuffBelonging", f"{basic_actor.player}")
            self.log("buffs after bound treasure")
            self.log(new_buffs)
            buff = 0
            for new_buff in new_buffs:
                if new_buff not in ori_buffs:
                    buff = new_buff
                    break
            if buff:
                self.log("new buff added")
                buff_value = basic_actor.getValue("Buff", f"{buff}")
                self.log("buff.getValue after bound treasure")
                self.log(buff_value)
            else:
                self.log("no buff added")
            treasure_timer = basic_actor.getValue("TreasureTimer", f"{treasure_id}")
            self.log("treasure timer after bound treasure")
            self.log(treasure_timer)
            self.log("unbounding treasure")
            result = basic_actor.send("UnboundTreasure", f"{treasure_id}")
            self.log(result['hash'])
            treasure_bounded = basic_actor.has("TreasureBounded", f"{treasure_id}")
            self.log("treasureBounded.has")
            self.log(treasure_bounded)
            if treasure_bounded:
                self.log("treasure unbound failed")
            else:
                self.log("treasure unbound success")
                ori_buffs = new_buffs
                new_buffs = basic_actor.getEntitiesWithValue("BuffBelonging", f"{basic_actor.player}")
                self.log("buffs after unbound treasure")
                self.log(new_buffs)
                buff = 0
                for ori_buff in ori_buffs:
                    if ori_buff not in new_buffs:
                        buff = ori_buff
                        break
                if buff:
                    self.log("buff removed")
                else:
                    self.log("no buff removed")
                treasure_timer = basic_actor.getValue("TreasureTimer", f"{treasure_id}")
                self.log("treasure timer after unbound treasure")
                self.log(treasure_timer)
        else:
            self.log("pick up failed")
        self.log("move to 19121410463005164307149571097624914303252356622127636921228827670930113884904")
        result = basic_actor.send("Movev2", "(19121410463005164307149571097624914303252356622127636921228827670930113884904,50,100,44444,6548174236596742820902339565391718630727264115530773170571288163083533194409,44444,1,[19446202452457351522801653655309720573261655219707282149402547323379358953194,18437548157660369709132993246863796195403731516222575830070375914041383068562],[[2428297405637387392464062693129358231959268506037548488203198079862988593003,4597175306526925804805491423460260977261941221373445480595020953793767697805],[15994097498884585473748996918196073411144129639084862365864825513223242184580,13212513978810055112386920328832701807183088497284857480151855528862735804520]],[21810154765094023602818511944926043004337161146034501048015442021432780677965,20953631223398425289572399393287122486558792096707090854445137154930589539657])")
        self.log(result['hash'])
        hidden_position = basic_actor.getValue("HiddenPosition", f"{basic_actor.player}")
        self.log("position after move expect to be `19121410463005164307149571097624914303252356622127636921228827670930113884904`")
        self.log(hidden_position)
        target_names = {"Shield Generator", "Missile", "Automated Resource Mine"}
        # if len(actors.actors) < 2:
        #     actors.new_actor()
        # actor_1 = actors.actors[1]
        shield_id = 0
        missile_id = 0
        resource_id = 0
        # build & name in target_names
        while target_names:
            treasure_id, success = self.build_treasure(actors)
            if not success:
                self.log("build failed")
                break
            treasure = basic_actor.getValue("Treasurev2", f"{treasure_id}")
            self.log("treasure after build")
            self.log(treasure)
            treasure_effect = basic_actor.getValue("TreasureEffectv2", f"{treasure_id}")
            self.log("treasure_effect after build")
            self.log(treasure_effect)
            if treasure[0] in target_names:
                self.log(f"`{treasure[0]}` built")
                if treasure[0] == "Shield Generator":
                    shield_id = treasure_id
                elif treasure[0] == "Missile":
                    missile_id = treasure_id
                elif treasure[0] == "Automated Resource Mine":
                    resource_id = treasure_id
                # remove
                target_names.remove(treasure[0])
        if shield_id and missile_id and resource_id:
            # airdrop shield
            timer = basic_actor.getValue("TreasureTimer", f"{shield_id}")
            self.log("treasure.timer before charge:")
            self.log(timer)
            treasure = basic_actor.getValue("Treasurev2", f"{shield_id}")
            self.log("treasure before charge:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{shield_id}")
            self.log("treasure.effect before charge:")
            self.log(effect)
            self.log("charge defense shield")
            result = basic_actor.send("ChargeAirdropTreasure", f"({shield_id},{actors.get_verify(13,6)},{actors.get_verify(13,4)},{effect[1]})")
            self.log(result['hash'])
            treasure = basic_actor.getValue("Treasurev2", f"{shield_id}")
            self.log("treasure after charge:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{shield_id}")
            self.log("treasure.effect after charge:")
            self.log(effect)
            charging = basic_actor.getValue("TreasureAirdropCharging", f"{shield_id}")
            self.log("treasure.charging after charge:")
            self.log(charging)
            timer = basic_actor.getValue("TreasureTimer", f"{shield_id}")
            self.log("treasure.timer after charge:")
            self.log(timer)
            if timer[1] > time.time():
                time.sleep(timer[1] - int(time.time()) + 1)
            self.log("release defense shield")
            result = basic_actor.send("ReleaseAirdropTreasure", f"({shield_id},[{actors.get_verify(13,4)}],[{actors.get_verify(13,4)},{actors.get_verify(13,3)},{actors.get_verify(14,4)},{actors.get_verify(14,5)},{actors.get_verify(13,5)},{actors.get_verify(12,5)},{actors.get_verify(12,4)}])")
            self.log(result['hash'])
            treasure = basic_actor.getValue("Treasurev2", f"{shield_id}")
            self.log("treasure after release:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{shield_id}")
            self.log("treasure.effect after release:")
            self.log(effect)
            charging = basic_actor.has("TreasureAirdropCharging", f"{shield_id}")
            self.log("treasure.charging after release:")
            self.log(charging)
            timer = basic_actor.getValue("TreasureTimer", f"{shield_id}")
            self.log("treasure.timer after release:")
            self.log(timer)
            coord = (13, 4)
            entities = basic_actor.getEntitiesWithValue("HiddenPosition", f"{actors.coordToFogHash[coord]}")
            self.log("hiddenposition.entities after release:")
            self.log(entities)
            for coord in [(13,4),(13,3),(14,4),(14,5),(13,5),(12,5),(12,4)]:
                entities = basic_actor.getEntitiesWithValue("ShieldAreaPosition", f"{actors.coordToFogHash[coord]}")
                self.log(f"shieldAreaPosition.entities at coord ({coord[0]},{coord[1]}):")
                self.log(entities)
            # test missile
            timer = basic_actor.getValue("TreasureTimer", f"{missile_id}")
            self.log("treasure.timer before charge:")
            self.log(timer)
            treasure = basic_actor.getValue("Treasurev2", f"{missile_id}")
            self.log("treasure before charge:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{missile_id}")
            self.log("treasure.effect before charge:")
            self.log(effect)
            self.log("charge missile")
            result = basic_actor.send("ChargeLinearTreasure", f"({missile_id},{actors.get_verify(13,6)},0,{treasure[5]},{effect[1]})")
            self.log(result['hash'])
            treasure = basic_actor.getValue("Treasurev2", f"{missile_id}")
            self.log("treasure after charge:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{missile_id}")
            self.log("treasure.effect after charge:")
            self.log(effect)
            charging = basic_actor.getValue("TreasureLinearCharging", f"{missile_id}")
            self.log("treasure.charging after charge:")
            self.log(charging)
            timer = basic_actor.getValue("TreasureTimer", f"{missile_id}")
            self.log("treasure.timer after charge:")
            self.log(timer)
            if timer[1] > time.time():
                time.sleep(timer[1] - int(time.time()) + 1)
            self.log("release missile")
            result = basic_actor.send("ReleaseLinearTreasure", f"({missile_id},[{actors.get_verify(13,5)},{actors.get_verify(13,4)}],[{actors.get_verify(13,4)},{actors.get_verify(13,3)},{actors.get_verify(14,4)},{actors.get_verify(14,5)},{actors.get_verify(13,5)},{actors.get_verify(12,5)},{actors.get_verify(12,4)}])")
            self.log(result['hash'])
            treasure = basic_actor.getValue("Treasurev2", f"{missile_id}")
            self.log("treasure after release:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{missile_id}")
            self.log("treasure.effect after release:")
            self.log(effect)
            charging = basic_actor.has("TreasureLinearCharging", f"{missile_id}")
            self.log("treasure.charging after release:")
            self.log(charging)
            timer = basic_actor.getValue("TreasureTimer", f"{missile_id}")
            self.log("treasure.timer after release:")
            self.log(timer)

            # airdrop resource
            timer = basic_actor.getValue("TreasureTimer", f"{resource_id}")
            self.log("treasure.timer before charge:")
            self.log(timer)
            treasure = basic_actor.getValue("Treasurev2", f"{resource_id}")
            self.log("treasure before charge:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{resource_id}")
            self.log("treasure.effect before charge:")
            self.log(effect)
            self.log("charge auto resource miner")
            result = basic_actor.send("ChargeAirdropTreasure", f"({resource_id},{actors.get_verify(13,6)},{actors.get_verify(13,4)},{effect[1]})")
            self.log(result['hash'])
            treasure = basic_actor.getValue("Treasurev2", f"{resource_id}")
            self.log("treasure after charge:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{resource_id}")
            self.log("treasure.effect after charge:")
            self.log(effect)
            charging = basic_actor.getValue("TreasureAirdropCharging", f"{resource_id}")
            self.log("treasure.charging after charge:")
            self.log(charging)
            timer = basic_actor.getValue("TreasureTimer", f"{resource_id}")
            self.log("treasure.timer after charge:")
            self.log(timer)
            if timer[1] > time.time():
                time.sleep(timer[1] - int(time.time()) + 1)
            self.log("airdrop auto resource miner")
            result = basic_actor.send("ReleaseAirdropTreasure", f"({resource_id},[{actors.get_verify(13,4)}],[{actors.get_verify(13,4)},{actors.get_verify(13,3)},{actors.get_verify(14,4)},{actors.get_verify(14,5)},{actors.get_verify(13,5)},{actors.get_verify(12,5)},{actors.get_verify(12,4)}])")
            self.log(result['hash'])
            treasure = basic_actor.getValue("Treasurev2", f"{resource_id}")
            self.log("treasure after release:")
            self.log(treasure)
            effect = basic_actor.getValue("TreasureEffectv2", f"{resource_id}")
            self.log("treasure.effect after release:")
            self.log(effect)
            charging = basic_actor.has("TreasureAirdropCharging", f"{resource_id}")
            self.log("treasure.charging after release:")
            self.log(charging)
            timer = basic_actor.getValue("TreasureTimer", f"{resource_id}")
            self.log("treasure.timer after release:")
            self.log(timer)
            # test resource
            resource_building_id = 0
            coord = (13, 4)
            entities = basic_actor.getEntitiesWithValue("ResourceBuildingPosition", f"{actors.coordToFogHash[coord]}")
            self.log("resourceBuildingPosition.entities after release:")
            self.log(entities)
            if entities:
                resource_building_id = entities[0]
            if resource_building_id:
                resource_building = basic_actor.getValue("ResourceBuilding", f"{resource_building_id}")
                powNonce = self.getPowNonce(resource_building_id, resource_building[0])
                self.log("dig auto resource miner")
                result = basic_actor.send("DigResourceBuilding", f"(9109964923784555505756535058688411810040322501253582306549209238152275236278,17960145934645911381904120820539289306682005468741135871524991943190207243035,50,100,22222,44444,11111,8765,4321,[10633873654751151500406334891474788343996447193870396796761254139885773294006,21172572420063424510400648665126060344689180801583455677862855258707893943867],[[14573539369983984301494312895322282094288942217974145346054367642130139647827,19489713785084215592438217107182573273839440920109217475837034571721265846381],[985227536087288225529706815718484103509291184974652944938411319630742122817,18721704193044111674153214785780324121739745972284401324809475457312055610120]],[19964081693964630312448382024943980467179380557118161614213246621480139343755,18268857596641062558343256632331042671643225134508655393367882455009143509663],{resource_building_id},[{powNonce}])")
                self.log(result['hash'])
                has_mining = basic_actor.has("ResourceMiningv2", f"{resource_building_id}")
                self.log("resourcemining.has after dig resource building")
                self.log(has_mining)
                if has_mining:
                    self.log("resource minging success")
                    resource_mining = basic_actor.getValue("ResourceMiningv2", f"{resource_building_id}")
                    self.log("resourcemining after dig resource building")
                    self.log(resource_mining)
                else:
                    self.log("resource minging failed")
        return
    
    def getPowNonce(self, resource_building_id, difficulty):
        for i in range(1000000000):
            result = int(Web3.toHex(Web3.solidityKeccak(['uint256', 'uint256'], [resource_building_id, i])), 16)
            if result % (2 ** difficulty) == 0:
                self.log(f"pow nonce: {i}")
                return i
