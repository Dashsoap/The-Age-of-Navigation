from script.systems.System import System
from script.testSystem import Actors

class GuildSystem(System):
    def __init__(self) -> None:
        self.name = "GuildSystem"
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
        basic_actor = actors.actors[0]
        # create guild
        oriGuilds = basic_actor.getEntitiesWithValue("GuildCrestPlayer", f"{basic_actor.player}")
        self.log("guildCrests before Create Guild:")
        self.log(oriGuilds)
        self.log("start creating guild")
        result = basic_actor.send("CreateGuild", '(19121410463005164307149571097624914303252356622127636921228827670930113884904,50,100,44444,[19583016230018659651638193773422066779534308211312443350543911849895280819478,20812541270714269138370480590757611334286638454220554316849726181187838600039],[[16170812011136300471415431488992509345881549743106382769295884119961293891204,1911324623922008157685595683343707842724723070425697017835135913902792932222],[5000023334473487867931238522597928397760644018002526609155290271182687236308,9732472076978886688912736174530673755747796395739250859746473612895373872690]],[11888322684322355968720651693287104912957443335103278831088642034705428114073,7177926381969015139278263735883955141777717478981616839203729294442034811946],"3_star_2_line","Axe Gang","The Guild President can post the recruitment information of the guild here.",0)')
        self.log(result['hash'])
        newGuilds = basic_actor.getEntitiesWithValue("GuildCrestPlayer", f"{basic_actor.player}")
        self.log("guildCrests after Create Guild:")
        self.log(newGuilds)
        new_guild_crest = 0
        for guild_crest in newGuilds:
            if guild_crest not in oriGuilds:
                new_guild_crest = guild_crest
                break
        if not new_guild_crest:
            self.log("create guild fail")
        else:
            self.log("create guild success")
            self.log("crest.id:")
            self.log(new_guild_crest)
            crest = basic_actor.getValue("GuildCrest", f"{new_guild_crest}")
            self.log("self.crest:")
            self.log(crest)
            # get Guild infos
            guild_id = basic_actor.getValue("GuildCrestGuild", f"{new_guild_crest}")
            self.log("guild.id:")
            self.log(guild_id)
            guild_position = basic_actor.getValue("HiddenPosition", f"{guild_id}")
            self.log("guild.position:")
            self.log(guild_position)
            guild = basic_actor.getValue("Guild", f"{guild_id}")
            self.log("guild:")
            self.log(guild)
            guild_display = basic_actor.getValue("GuildDisplay", f"{basic_actor.player}")
            self.log("player.guildDisplay:")
            self.log(guild_display)
            # donate treasure
            treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
            self.log("self.treasures before donate")
            self.log(treasures)
            guild_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{guild_id}")
            self.log("guild_treasures before donate")
            self.log(guild_treasures)
            if treasures:
                treasure_id = treasures[0]
                self.log("donating treasure")
                result = basic_actor.send("DonateTreasure", f"({new_guild_crest},{treasure_id})")
                self.log(result['hash'])
                treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
                self.log("self.treasures after donate")
                self.log(treasures)
                new_guild_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{guild_id}")
                self.log("guild_treasures after donate")
                self.log(new_guild_treasures)
                found = False
                for treasure in new_guild_treasures:
                    if treasure == treasure_id:
                        found = True
                        break
                if found:
                    self.log("donate success")
                    crest = basic_actor.getValue("GuildCrest", f"{new_guild_crest}")
                    self.log("self.crest:")
                    self.log(crest)
                    # allocate treasure
                    self.log("allocating treasure")
                    result = basic_actor.send("AllocateTreasure", f"({new_guild_crest},{treasure_id})")
                    self.log(result['hash'])
                    new_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{basic_actor.player}")
                    self.log("self.new_treasures after donate")
                    self.log(new_treasures)
                    found = False
                    for treasure in new_treasures:
                        if treasure not in treasures and treasure == treasure_id:
                            found = True
                            break
                    if found:
                        self.log("allocate success")
                    else:
                        self.log("allocate failed")
                        raise ValueError("allocate failed")
                    guild_treasures = basic_actor.getEntitiesWithValue("PlayerBelonging", f"{guild_id}")
                    self.log("guild_treasures after donate")
                    self.log(guild_treasures)
                    found = False
                    for treasure in new_guild_treasures:
                        if treasure not in guild_treasures and treasure == treasure_id:
                            found = True
                            break
                    if found:
                        self.log("allocate success")
                    else:
                        self.log("allocate failed")
                else:
                    self.log("donate failed")
                    raise ValueError("donate failed")
            # donate resource
            guild_resource = basic_actor.getValue("GoldAmount", f"{guild_id}")
            self.log("guild_resource before donate:")
            self.log(guild_resource)
            self.log("start donating resource")
            result = basic_actor.send("DonateResource", f"({new_guild_crest},0,15)")
            self.log(result['hash'])
            resource = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
            self.log("resource after donate:")
            self.log(resource)
            guild_resource = basic_actor.getValue("GoldAmount", f"{guild_id}")
            self.log("guild_resource after donate:")
            self.log(guild_resource)
            self.log("start allocating resource")
            result = basic_actor.send("AllocateResource", f"({new_guild_crest},0,15)")
            self.log(result['hash'])
            resource = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
            self.log("resource after allocate:")
            self.log(resource)
            guild_resource = basic_actor.getValue("GoldAmount", f"{guild_id}")
            self.log("guild_resource after allocate:")
            self.log(guild_resource)
            # join guild
            if len(actors.actors) < 2:
                actors.new_actor()
            actor_1 = actors.actors[1]
            oriGuilds = actor_1.getEntitiesWithValue("GuildCrestPlayer", f"{actor_1.player}")
            self.log("guildCrests before Join Guild:")
            self.log(oriGuilds)
            self.log("start joining guild")
            result = actor_1.send("JoinGuild", f"({guild_id},)")
            self.log(result['hash'])
            newGuilds = actor_1.getEntitiesWithValue("GuildCrestPlayer", f"{actor_1.player}")
            self.log("guildCrests after Join Guild:")
            self.log(newGuilds)
            guild_crest_1 = 0
            for guild_crest in newGuilds:
                if guild_crest not in oriGuilds:
                    guild_crest_1 = guild_crest
                    break
            if not guild_crest_1:
                self.log("join guild fail")
            else:
                self.log("join guild (penging) success")
                self.log("crest.id:")
                self.log(guild_crest_1)
                guild_pending = actor_1.getValue("GuildCrestPending", f"{guild_crest_1}")
                self.log("crest.pending:")
                self.log(guild_pending)
                crest = actor_1.getValue("GuildCrest", f"{guild_crest_1}")
                self.log("crest:")
                self.log(crest)
                # approve
                self.log("start approving")
                result = basic_actor.send("ApproveGuild", f"({guild_crest_1},)")
                self.log(result['hash'])
                guild_pending = actor_1.has("GuildCrestPending", f"{guild_crest_1}")
                self.log("crest.pending.has:")
                self.log(guild_pending)
                if not guild_pending:
                    self.log("approve success")
                    crest = actor_1.getValue("GuildCrest", f"{guild_crest_1}")
                    self.log("crest:")
                    self.log(crest)
                    # adjust to manager
                    self.log("start setting target to manager(2) level")
                    result = basic_actor.send("AdjustGuildMember", f"({guild_crest_1},2)")
                    self.log(result['hash'])
                    crest = actor_1.getValue("GuildCrest", f"{guild_crest_1}")
                    self.log("crest after Adjust level:")
                    self.log(crest)
                    self.log("start transfering leader to target")
                    result = basic_actor.send("TransferGuildLeader", f"({guild_crest_1},)")
                    self.log(result['hash'])
                    crest = basic_actor.getValue("GuildCrest", f"{new_guild_crest}")
                    self.log("source.crest after transfer leader:")
                    self.log(crest)
                    crest = actor_1.getValue("GuildCrest", f"{guild_crest_1}")
                    self.log("target.crest after transfer leader:")
                    self.log(crest)
                    self.log("start kicking self out of guild")
                    result = basic_actor.send("KickGuildMember", f"({new_guild_crest},)")
                    self.log(result['hash'])
                    crest_has = basic_actor.has("GuildCrest", f"{new_guild_crest}")
                    self.log("source.crest.has after kick:")
                    self.log(crest_has)
                else:
                    self.log("approve failed")
        return
