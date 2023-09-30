from typing import Any, List, Dict
import os
import json
from web3 import Web3
import time

abs_path = os.path.dirname(os.path.realpath(__file__))

class System:
    def __init__(self) -> None:
        self.name = "System"
        self.components = list()
        self.systems = list()
        self.system_input = dict()
    
    def log(self, info: Any) -> None:
        print(info)
        if isinstance(info, tuple):
            info = list(info)
        if isinstance(info, (list, dict)):
            info = json.dumps(info, ensure_ascii=False, separators=(",", ":"))
        if not isinstance(info, str):
            info = str(info)
        with open(os.path.join(abs_path, "..", "logs", "test.log"), "a", encoding="utf-8") as log_file:
            log_file.write(f"{info}\n")
    
    def get_systems(self) -> List[str]:
        return self.systems + ["BulkSetState", "ComponentDev"]
    
    def get_components(self) -> List[Dict[str, str]]:
        return self.components
    
    def load_inputs(self) -> List[str]:
        if os.path.exists(os.path.join(abs_path, "inputs", f"{self.name}.json")):
            with open(os.path.join(abs_path, "inputs", f"{self.name}.json"), "r", encoding="utf-8") as input_file:
                return json.loads(input_file.read())
        return list()
    
    def changeValue(self, mud, component: str, entity: int, values: str):
        componentId = eval(Web3.solidityKeccak(["string"], [f"component.{component}"]).hex())
        # value = Web3.toBytes(values)
        value = values.encode()
        self.log("change value")
        result = mud.send("ComponentDev", f"{componentId},{entity},{value}")
        self.log(result['hash'])
    
    def execute(self, mud, info: Dict[str, Any]):
        print(info["msg"])
        if info["method"] == "getValue":
            print(mud.getValue(info["name"], info["params"]))
        elif info["method"] == "getEntitiesWithValue":
            print(mud.getEntitiesWithValue(info["name"], info["params"]))
        elif info["method"] == "system":
            system_name = info["name"]
            system_input_info = self.system_input.get(system_name, dict())
            if not system_input_info:
                raise KeyError("System not registered to test program")
            params = system_input_info.get("formatter", "")
            for param in system_input_info.get("params", list()):
                print(param, str(info["params"].get(param, "")))
                param_value = info["params"].get(param, "")
                if isinstance(param_value, str):
                    param_value = f'"{param_value}"'
                else:
                    param_value = str(param_value)
                params = params.replace(param, param_value)
            print(f"execute: {system_name}, params: {params}")
            mud.send(system_name, params)
            time.sleep(3)
        elif info["method"] == "assert":
            if info["type"] == "hasValue":
                if not mud.has(info["name"], info["params"]):
                    raise ValueError(info["error"])
        elif info["method"] == "getSchema":
            print(mud.getSchema(info["name"]))
        elif info["method"] == "devChange":
            system_name = "ComponentDev"
            component_name = info["name"]
            component_id = eval(Web3.solidityKeccak(["string"], [f"component.{component_name}"]).hex())
            entity = info["params"]["entity"]
            value = info["params"]["value"]
            datatype = info["params"]["datatype"]
            value = Web3.eth.abi.encode_abi(datatype, value)
            print(mud.send(system_name, f"({component_id},{entity},{value})"))
            time.sleep(3)
    
    def execute_test(self, actors):
        pass
