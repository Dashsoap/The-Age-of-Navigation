from script.systems.System import System

class MarkSystem(System):
    def __init__(self) -> None:
        self.name = "MarkSystem"
        self.components = [
            "SpaceTimeMarker",
        ]
        self.systems = [
            "Mark",
        ]
        self.system_input = {
            "Mark": {
                "formatter": "({coordHash},{width},{height},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}])",
                "params": [
                    "{coordHash}",
                    "{width}",
                    "{height}",
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

if __name__ == "__main__":
    ms = MarkSystem()
    ms.get_systems()
