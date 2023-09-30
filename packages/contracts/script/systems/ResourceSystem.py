from script.systems.System import System

class ResourceSystem(System):
    def __init__(self) -> None:
        self.name = "ResourceSystem"
        self.components = [
            "ResourceMiningv2",
            "Resourcev2",
            "SpaceTimeMarker",
            "GoldAmount",
            "MapConfigv2",
        ]
        self.systems = [
            "DigResourcev2",
            "TakeResourcev2",
        ]
        self.system_input = {
            "DigResourcev2": {
                "formatter": "({realHash},{fogHash},{width},{height},{terrainSeed},{fogSeed},{resourceSeed},{terrainPerlin},{resourcePerlin},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}],{powNonce})",
                "params": [
                    "{realHash}",
                    "{fogHash}",
                    "{width}",
                    "{height}",
                    "{terrainSeed}",
                    "{fogSeed}",
                    "{resourceSeed}",
                    "{terrainPerlin}",
                    "{resourcePerlin}",
                    "{a[0]}",
                    "{a[1]}",
                    "{b[0][0]}",
                    "{b[0][1]}",
                    "{b[1][0]}",
                    "{b[1][1]}",
                    "{c[0]}",
                    "{c[1]}",
                    "{powNonce}"
                ]
            },
            "TakeResourcev2": {
                "formatter": "({realHash},{fogHash},{width},{height},{terrainSeed},{fogSeed},{resourceSeed},{terrainPerlin},{resourcePerlin},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}])",
                "params": [
                    "{realHash}",
                    "{fogHash}",
                    "{width}",
                    "{height}",
                    "{terrainSeed}",
                    "{fogSeed}",
                    "{resourceSeed}",
                    "{terrainPerlin}",
                    "{resourcePerlin}",
                    "{a[0]}",
                    "{a[1]}",
                    "{b[0][0]}",
                    "{b[0][1]}",
                    "{b[1][0]}",
                    "{b[1][1]}",
                    "{c[0]}",
                    "{c[1]}",
                ]
            }
        }
    
    def execute_test(self, actors):
        basic_actor = actors.actors[0]
        resource = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
        self.log("resource before componentDev:")
        self.log(resource)
        self.changeValue(basic_actor, "GoldAmount", basic_actor.player, "0x0000000000000000000000000000000000000000000000000000000000000014")
        self.changeValue(basic_actor, "GoldAmount", 482126752125167345004674823000425555327562203062, "0x0000000000000000000000000000000000000000000000000000000000000014")
        resource = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
        self.log("resource after componentDev:")
        self.log(resource)
        self.log("set resource success")
        return 
