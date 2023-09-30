import time

from script.systems.System import System
from script.testSystem import Actors

class TechSystem(System):
    def __init__(self) -> None:
        self.name = "TechSystem"
        self.components = [
            "TechBelonging",
            "Tech",
            "TechConfig",
            "TechConfigRegister",
            "TechConfigGlobal",
            "TechUpdating",
            "TechUpdatingPlayer",
        ]
        self.systems = [
            "TechUpdate",
            "TechFinish",
            "TechCancel",
            "TechAccelerate",
        ]
        self.system_input = {
            "TechUpdate": {
                "formatter": "({nextLevel},{techGroupId})",
                "params": [
                    "{nextLevel}",
                    "{techGroupId}"
                ]
            },
            "TechFinish": {
                "formatter": "({updateId})",
                "params": [
                    "{updateId}"
                ]
            },
            "TechCancel": {
                "formatter": "({updateId})",
                "params": [
                    "{updateId}"
                ]
            },
            "TechAccelerate": {
                "formatter": "({updateId})",
                "params": [
                    "{updateId}"
                ]
            }
        }
    
    def execute_test(self, actors: Actors):
        basic_actor = actors.actors[0]
        # start update
        techConfigs = basic_actor.getEntitiesWithValue("TechConfigRegister", f"{basic_actor.singletonID}")
        if not techConfigs:
            self.log("no tech config registered")
            return
        target_config_id = techConfigs[0]
        target_config = basic_actor.getValue("TechConfig", f"{target_config_id}")
        self.log("tech_config")
        self.log(target_config)
        tech_group_id = target_config_id
        self.log("tech_gourp_id")
        self.log(tech_group_id)

        ori_updatings = basic_actor.getEntitiesWithValue("TechUpdatingPlayer", f"{basic_actor.player}")
        self.log("updatings before Update")
        self.log(ori_updatings)
        ori_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs before Update")
        self.log(ori_techs)
        last_level = 0
        self.log("tech updating")
        result = basic_actor.send("TechUpdate", f"({last_level+1},{tech_group_id})")
        self.log(result['hash'])
        new_updatings = basic_actor.getEntitiesWithValue("TechUpdatingPlayer", f"{basic_actor.player}")
        self.log("updatings after Update")
        self.log(new_updatings)
        new_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs after Update")
        self.log(new_techs)
        updating_id = 0
        for update_id in new_updatings:
            if update_id not in ori_updatings:
                updating_id = update_id
                break
        if not updating_id:
            self.log("update failed")
            return
        self.log("update success")
        update = basic_actor.getValue("TechUpdating", f"{updating_id}")
        self.log("update.info:")
        self.log(update)

        # cancel update
        self.log("canceling update")
        gold = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
        self.log("gold before cancel")
        self.log(gold)
        result = basic_actor.send("TechCancel", f"({updating_id},)")
        self.log(result['hash'])
        has_updating_player = basic_actor.has("TechUpdatingPlayer", f"{updating_id}")
        self.log("techUpdatingPlayer.has:")
        self.log(has_updating_player)
        has_updating = basic_actor.has("TechUpdating", f"{updating_id}")
        self.log("techUpdating.has:")
        self.log(has_updating)
        gold = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
        self.log("gold after cancel")
        self.log(gold)
        if has_updating or has_updating_player:
            self.log("cancel failed")
            return
        self.log("cancel success")
        
        # restart update & finish
        ori_updatings = basic_actor.getEntitiesWithValue("TechUpdatingPlayer", f"{basic_actor.player}")
        self.log("updatings before Update")
        self.log(ori_updatings)
        ori_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs before Update")
        self.log(ori_techs)
        last_level = 0
        self.log("tech updating")
        result = basic_actor.send("TechUpdate", f"({last_level+1},{tech_group_id})")
        self.log(result['hash'])
        new_updatings = basic_actor.getEntitiesWithValue("TechUpdatingPlayer", f"{basic_actor.player}")
        self.log("updatings after Update")
        self.log(new_updatings)
        new_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs after Update")
        self.log(new_techs)
        updating_id = 0
        for update_id in new_updatings:
            if update_id not in ori_updatings:
                updating_id = update_id
                break
        if not updating_id:
            self.log("update failed")
            return
        self.log("update success")
        update = basic_actor.getValue("TechUpdating", f"{updating_id}")
        self.log("update.info:")
        self.log(update)
        if update[2] > int(time.time()):
            time.sleep(int(update[2] - int(time.time()) + 1))
        ori_techs = new_techs
        ori_updatings = new_updatings
        self.log("finish updating")
        result = basic_actor.send("TechFinish", f"({updating_id},)")
        self.log(result['hash'])
        has_updating_player = basic_actor.has("TechUpdatingPlayer", f"{updating_id}")
        self.log("techUpdatingPlayer.has:")
        self.log(has_updating_player)
        has_updating = basic_actor.has("TechUpdating", f"{updating_id}")
        self.log("techUpdating.has:")
        self.log(has_updating)
        if has_updating or has_updating_player:
            self.log("finish failed")
            return
        new_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs after Update")
        self.log(new_techs)
        finish_id = 0
        for tech_id in new_techs:
            if tech_id not in ori_techs:
                finish_id = tech_id
                break
        if not finish_id:
            self.log("finish failed")
            return
        self.log("finish success")
        # TODO: has new buff && new buff source == "Tech" && new buff sourceId == finish_id
        tech = basic_actor.getValue("Tech", f"{finish_id}")
        self.log("tech.info:")
        self.log(tech)
        last_level = tech[0]
        
        # new update & accelerate
        time.sleep(5 * 2 * 2)
        ori_updatings = basic_actor.getEntitiesWithValue("TechUpdatingPlayer", f"{basic_actor.player}")
        self.log("updatings before Update")
        self.log(ori_updatings)
        ori_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs before Update")
        self.log(ori_techs)
        self.log("tech updating")
        result = basic_actor.send("TechUpdate", f"({last_level+1},{tech_group_id})")
        self.log(result['hash'])
        new_updatings = basic_actor.getEntitiesWithValue("TechUpdatingPlayer", f"{basic_actor.player}")
        self.log("updatings after Update")
        self.log(new_updatings)
        new_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs after Update")
        self.log(new_techs)
        updating_id = 0
        for update_id in new_updatings:
            if update_id not in ori_updatings:
                updating_id = update_id
                break
        if not updating_id:
            self.log("update failed")
            return
        self.log("update success")
        update = basic_actor.getValue("TechUpdating", f"{updating_id}")
        self.log("update.info:")
        self.log(update)
        # if update[2] > int(time.time()):
        #     time.sleep(int(update[2] - int(time.time()) + 1))
        ori_techs = new_techs
        ori_updatings = new_updatings
        gold = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
        self.log("gold before cancel")
        self.log(gold)
        self.log("accelerate updating")
        result = basic_actor.send("TechAccelerate", f"({updating_id},)")
        self.log(result['hash'])
        has_updating_player = basic_actor.has("TechUpdatingPlayer", f"{updating_id}")
        self.log("techUpdatingPlayer.has:")
        self.log(has_updating_player)
        has_updating = basic_actor.has("TechUpdating", f"{updating_id}")
        self.log("techUpdating.has:")
        self.log(has_updating)
        if has_updating or has_updating_player:
            self.log("accelerate failed")
            return
        new_techs = basic_actor.getEntitiesWithValue("TechBelonging", f"{basic_actor.player}")
        self.log("techs after Update")
        self.log(new_techs)
        gold = basic_actor.getValue("GoldAmount", f"{basic_actor.player}")
        self.log("gold after cancel")
        self.log(gold)
        accelerate_id = 0
        for tech_id in new_techs:
            tech = basic_actor.getValue("Tech", f"{tech_id}")
            if tech[0] == last_level + 1:
                accelerate_id = tech_id
                break
        if not accelerate_id:
            self.log("accelerate failed")
            return
        self.log("accelerate success")
        tech = basic_actor.getValue("Tech", f"{accelerate_id}")
        self.log("tech.info:")
        self.log(tech)
