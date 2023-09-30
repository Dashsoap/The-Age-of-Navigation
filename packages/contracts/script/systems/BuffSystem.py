from script.systems.System import System

class BuffSystem(System):
    def __init__(self) -> None:
        self.name = "BuffSystem"
        self.components = [
            "BuffBelonging",
            "Buff",
            "BuffConfig",
            "BuffConfigRegister",
        ]
        self.systems = [
        ]
        self.system_input = {
        }
