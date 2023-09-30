from script.systems.System import System
from script.testSystem import Actors

class SimpleTestSystem(System):
    def __init__(self) -> None:
        self.name = "SimpleTestSystem"
        self.components = [
            "Guild",
            "GuildCrest",
            "GuildCrestGuild",
            "GuildCrestPlayer",
            "GuildDisplay",
        ]
        self.systems = [
            "CreateGuild",
            "JoinGuild",
            "ApproveGuild",
            "KickGuildMember",
            "TransferGuildLeader",
            "AdjustGuildMember",
            "DonateResource",
            "DonateTreasure",
            "AllocateResource",
            "AllocateTreasure",
        ]
        self.system_input = {
            "CreateGuild": {
                "formatter": "({flag},{name},{description},{regime})",
                "params": [
                    "{flag}",
                    "{name}",
                    "{description}",
                    "{regime}",
                ]
            },
            "JoinGuild": {
                "formatter": "{guildId}",
                "params": [
                    "{guildId}",
                ]
            },
            "ApproveGuild": {
                "formatter": "{guildCrestId}",
                "params": [
                    "{guildCrestId}",
                ]
            },
            "KickGuildMember": {
                "formatter": "{guildCrestId}",
                "params": [
                    "{guildCrestId}",
                ]
            },
            "TransferGuildLeader": {
                "formatter": "{guildCrestId}",
                "params": [
                    "{guildCrestId}",
                ]
            },
            "AdjustGuildMember": {
                "formatter": "({guildCrestId},{level})",
                "params": [
                    "{guildCrestId}",
                    "{level}",
                ]
            },
            "DonateResource": {
                "formatter": "({guildCrestId},{resourceType},{amount})",
                "params": [
                    "{guildCrestId}",
                    "{resourceType}",
                    "{amount}",
                ]
            },
            "DonateTreasure": {
                "formatter": "({guildCrestId},{treasureId})",
                "params": [
                    "{guildCrestId}",
                    "{treasureId}",
                ]
            },
            "AllocateResource": {
                "formatter": "({guildCrestId},{resourceType},{amount})",
                "params": [
                    "{guildCrestId}",
                    "{resourceType}",
                    "{amount}",
                ]
            },
            "AllocateTreasure": {
                "formatter": "({guildCrestId},{treasureId})",
                "params": [
                    "{guildCrestId}",
                    "{treasureId}",
                ]
            },
        }

    def execute_test(self, actors: Actors):
        actor_1 = actors.actors[0]
        # tid = 482126752125167345004674823000425555327562203062
        # amount = actor_1.getValue("GoldAmount", f"{tid}")
        # self.log(amount)
        # self.changeValue(actor_1, "GoldAmount", tid, "0x0000000000000000000000000000000000000000000000000000000000000014")
        # amount = actor_1.getValue("GoldAmount", f"{tid}")
        # self.log(amount)
        # entities = actor_1.getEntities("ResourceBuilding")
        entities = [eval("0x02c297ab74aad0aede3a1895c857b1f2c71e6a203feb727bec95ac752998cb78"), eval("0xc992a4f4c614c6258b392474376b00c403ba311ad1b24c06537a7c109387f977")]
        for entity in entities:
            self.log({"resourceId": entity, "hex": hex(entity)})
            position = actor_1.getValue("ResourceBuildingPosition", f"{entity}")
            self.log("resourcebuilding.position:")
            self.log({"position": position, "hex": hex(position)})
            owner = actor_1.getValue("ResourceBuildingPlayer", f"{entity}")
            self.log("resourcebuilding.owner:")
            self.log({"owner": owner, "hex": hex(owner)})
            areas = actor_1.getEntitiesWithValue("ResourceBuildingAreaBuilding", f"{entity}")
            self.log("area.ids:")
            self.log(areas)
            for area in areas:
                self.log({"area.id": area, "hex": hex(area)})
                coord = actor_1.getValue("ResourceBuildingAreaPosition", f"{area}")
                self.log("area.position:")
                self.log({"position": coord, "hex": hex(coord)})
                resourceBuildings = actor_1.getEntitiesWithValue("ResourceBuildingPosition", f"{coord}")
                self.log("area.resourceBuildings:")
                self.log({"resourceBuildings": resourceBuildings, "count": len(resourceBuildings)})
        return
