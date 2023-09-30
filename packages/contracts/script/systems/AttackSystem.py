import time
from script.systems.System import System
from script.testSystem import Actors

class AttackSystem(System):
    def __init__(self) -> None:
        self.name = "AttackSystem"
        self.components = [
            "AttackCharge",
            "AttackTimer",
            "Charging"
        ]
        self.systems = [
            "AttackCharge",
            "AttackFinish",
        ]
        self.system_input = {
            "AttackCharge": {
                "formatter": "({direction})",
                "params": [
                    "{direction}"
                ]
            },
            "AttackFinish": {
                "formatter": "({input},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}])",
                "params": [
                    "{input}",
                    "{a[0]}",
                    "{a[1]}",
                    "{b[0][0]}",
                    "{b[0][1]}",
                    "{b[1][0]}",
                    "{b[1][1]}",
                    "{c[0]}",
                    "{c[1]}"
                ]
            }
        }
    
    def execute_test(self, actors: Actors):
        basic_actor = actors.actors[0]
        if len(actors.actors) < 2:
            actors.new_actor()
        actor_1 = actors.actors[1]
        # charge
        self.log("attack charge")
        result = basic_actor.send("AttackCharge", f"(0,)")
        self.log(result['hash'])
        attack_charge = basic_actor.getValue("AttackCharge", f"{basic_actor.player}")
        self.log("AttackCharge.value after charge:")
        self.log(attack_charge)
        attack_timer = basic_actor.getValue("AttackTimer", f"{basic_actor.player}")
        self.log("AttackTimer.value after charge:")
        self.log(attack_timer)
        charging = basic_actor.getValue("Charging", f"{basic_actor.player}")
        self.log("ChargingComponent.value after charge:")
        self.log(charging)
        if attack_timer[1] > time.time():
            time.sleep(attack_timer[1] - int(time.time()) + 1)
        self.log("attack finish v2")
        result = basic_actor.send("AttackFinishv2", f"([{actors.get_verify(13,5)},{actors.get_verify(13,4)}],[{actors.get_verify(13,4)}])")
        self.log(result['hash'])
        attack_charge = basic_actor.has("AttackCharge", f"{basic_actor.player}")
        self.log("AttackCharge.has after charge:")
        self.log(attack_charge)
        attack_timer = basic_actor.has("AttackTimer", f"{basic_actor.player}")
        self.log("AttackTimer.has after charge:")
        self.log(attack_timer)
        charging = basic_actor.has("Charging", f"{basic_actor.player}")
        self.log("ChargingComponent.has after charge:")
        self.log(charging)
        # charge again
        self.log("attack charge")
        result = basic_actor.send("AttackCharge", f"(0,)")
        self.log(result['hash'])
        attack_charge = basic_actor.getValue("AttackCharge", f"{basic_actor.player}")
        self.log("AttackCharge.value after charge:")
        self.log(attack_charge)
        attack_timer = basic_actor.getValue("AttackTimer", f"{basic_actor.player}")
        self.log("AttackTimer.value after charge:")
        self.log(attack_timer)
        charging = basic_actor.getValue("Charging", f"{basic_actor.player}")
        self.log("ChargingComponent.value after charge:")
        self.log(charging)
        if attack_timer[1] > time.time():
            time.sleep(attack_timer[1] - int(time.time()) + 1)
        self.log("attack finish v2")
        result = basic_actor.send("AttackFinishv2", f"([{actors.get_verify(13,5)},{actors.get_verify(13,4)}],[{actors.get_verify(13,4)}])")
        self.log(result['hash'])
        attack_charge = basic_actor.has("AttackCharge", f"{basic_actor.player}")
        self.log("AttackCharge.has after charge:")
        self.log(attack_charge)
        attack_timer = basic_actor.has("AttackTimer", f"{basic_actor.player}")
        self.log("AttackTimer.has after charge:")
        self.log(attack_timer)
        charging = basic_actor.has("Charging", f"{basic_actor.player}")
        self.log("ChargingComponent.has after charge:")
        self.log(charging)
