import os
import json

project_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

json_obj = {
    "components": list(),
    "initializers": list(),
    "systems": list()
}
print("*** start generate ***")

for filename in os.listdir(os.path.join(project_dir, "src", "components")):
    if filename.endswith("Component.sol"):
        component = filename.partition(".")[0]
        json_obj["components"].append(component)
        print(f"add component: {component}")

for filename in os.listdir(os.path.join(project_dir, "src", "libraries")):
    if filename.endswith("Initializer.sol"):
        initializer = filename.partition(".")[0]
        json_obj["initializers"].append(initializer)
        print(f"add initializer: {initializer}")

for filename in os.listdir(os.path.join(project_dir, "src", "systems")):
    if filename.endswith("System.sol"):
        system = filename.partition(".")[0]
        info = {"name": system, "writeAccess": list()}
        with open(os.path.join(project_dir, "src", "systems", filename), "r", encoding="utf-8") as system_file:
            for line in system_file:
                if not line.strip():
                    continue
                if line.startswith("// components: "):
                    # // components: ["CounterComponent", "EncounterComponent", "OwnedByComponent"]
                    components = json.loads(line.strip().strip("// components: "))
                    info["writeAccess"] = components
                    break
        json_obj["systems"].append(info)
        print(f"add system: {system}")

with open(os.path.join(project_dir, "deploy.json"), "w", encoding="utf-8") as output_file:
    output_file.write(json.dumps(json_obj, ensure_ascii=False))
print("*** end generate ***")
