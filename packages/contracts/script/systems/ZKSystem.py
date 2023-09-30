from script.systems.System import System

class ZKSystem(System):
    def __init__(self) -> None:
        self.name = "ZKSystem"
        self.components = [
            "ZKConfig",
        ]
        self.systems = [
        ]
        self.system_input = {
        }
