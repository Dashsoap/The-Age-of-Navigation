import json, os, sys, random
from typing import Any, List, Dict, Tuple

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(abs_path, ".."))

from web3 import Web3, HTTPProvider, WebsocketProvider
from eth_account import Account

class Config:
    """Main configuration."""
    def __init__(self):

        # Read data.
        self.world_address = "0x31E6df9726A1b31FCD347c07b4c0B762BfB4782d"
        if os.path.exists(os.path.join(abs_path, "..", "world_address.txt")):
            with open(os.path.join(abs_path, "..", "world_address.txt")) as address_file:
                self.world_address = address_file.read().strip()
        self.w3_RPC = "https://follower.testnet-chain.linfra.xyz"
        self.w3_WSRPC = ""
        self.abi_dir = os.path.join(abs_path, "../abi")
        self.mud_components = [
            {"name": "ResourceDistribution", "types": ["uint32"]},
            {"name": "TreasureDistribution", "types": ["uint32"]},
            {"name": "Terrain", "types": ["uint32"]},
            {"name": "FogSeed", "types": ["uint32"]},
        ]
        self.mud_systems = [
            "ChangeResourceSeed",
            "ChangeSeed",
            "ChangeTreasureSeed",
            "ChangeFogSeed",
        ]

class Web3Connector(object):
    def __init__(self, contractAddress, RPC, WCRPC, PRIVATE_KEY, ABI):
        ADDRESS = Web3.toChecksumAddress(contractAddress)
        if RPC:
            self.w3 = Web3(HTTPProvider(RPC))
        elif WCRPC:
            self.w3 = Web3(WebsocketProvider(WCRPC))
        self.acct = self.w3.eth.account.privateKeyToAccount(PRIVATE_KEY)
        self.contract = self.w3.eth.contract(address=ADDRESS, abi=ABI)

    @staticmethod
    def user_to_address(user):
        return Web3.toChecksumAddress(user)
    
    @staticmethod
    def string_to_bytes32(string):
        return Web3.toBytes(hexstr=string)
    
    @staticmethod
    def to_text(bytes):
        return Web3.toText(bytes)
    
    @staticmethod
    def is_address_0(user):
        return user == "0x0000000000000000000000000000000000000000"

    def send(self, func):
        """send web3 request

        Args:
            func (str): _description_. 'funcName(params)'

        Returns:
            _type_: _description_
        """
        # while 1:
        nonce = self.w3.eth.getTransactionCount(self.acct.address)
        # print(action, nonce)
        try:
            # print(func)
            construct_txn = eval('self.contract.functions.{}'.format(func)).buildTransaction({
                'from': self.acct.address,
                'nonce': nonce,
                'gas': 30000000,
                'gasPrice': self.w3.toWei('21', 'gwei'),
            })
            signed = self.acct.signTransaction(construct_txn)
            tx_hash = self.w3.eth.sendRawTransaction(signed.rawTransaction)
            tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
            # print(tx_receipt)
            return {"hash": tx_hash.hex(), "result": tx_receipt}
        except Exception as e:
            print(func, "execute error:", str(e))
            # nonce += 1
            # if nonce >= 3:
            #     break
            return
    
    def async_send(self, func):
        """send web3 request

        Args:
            func (str): _description_. 'funcName(params)'

        Returns:
            _type_: _description_
        """
        while 1:
            nonce = self.w3.eth.getTransactionCount(self.acct.address)
            # print(action, nonce)
            try:
                # print(func)
                construct_txn = eval('self.contract.functions.{}'.format(func)).buildTransaction({
                    'from': self.acct.address,
                    'nonce': nonce,
                    'gas': 30000000,
                    'gasPrice': self.w3.toWei('21', 'gwei'),
                })
                signed = self.acct.signTransaction(construct_txn)
                tx_hash = self.w3.eth.sendRawTransaction(signed.rawTransaction)
                # tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
                # print(tx_receipt)
                # return {"hash": tx_hash.hex(), "result": tx_receipt}
            except Exception as e:
                print(func, "execute error:", str(e))
                nonce += 1
                if nonce >= 3:
                    return

    def transfer(self, func, amount):
        """send web3 request

        Args:
            func (str): _description_. 'funcName(params)'

        Returns:
            _type_: _description_
        """
        # while 1:
        nonce = self.w3.eth.getTransactionCount(self.acct.address)
        # print(action, nonce)
        try:
            construct_txn = eval('self.contract.functions.{}'.format(func)).buildTransaction({
                'from': self.acct.address,
                'nonce': nonce,
                'gas': 300000,
                'gasPrice': self.w3.toWei('21', 'gwei'),
                'value': int(amount),
            })
            signed = self.acct.signTransaction(construct_txn)
            tx_hash = self.w3.eth.sendRawTransaction(signed.rawTransaction)
            tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
            return {"hash": tx_hash.hex(), "result": tx_receipt}
        except Exception:
            # nonce += 1
            # if nonce >= 3:
                # break
            return

    def call(self, func1):
        # while 1:
        nonce = self.w3.eth.getTransactionCount(self.acct.address)
        try:
            func = 'self.contract.functions.{}'.format(func1)
            result = eval(func).call()
            return result
        except Exception as e:
            print(func1, "execute error:", str(e))
            return
            # nonce += 1
            # if nonce >= 3:
            #     break

    def searchEvent(self, event, fromBlock=0):
        event = "self.contract.events.{}".format(event)
        event_result = eval(event).createFilter(fromBlock=fromBlock).get_all_entries()
        return event_result

def new_account():
    account = Account.create()
    private_key = account.key
    return private_key.hex()

class MUDConnector(object):
    def __init__(self, private_key: str, cfg: Config, loadComponents=True) -> None:
        self.config = cfg
        self.private_key = private_key
        self.world = self._connect(cfg.world_address, "World.json")
        self.singletonID = 1549
        self.wallet = self.world.acct.address
        self.player = eval(self.wallet)
        if loadComponents:
            component_registry = self.world.call("components()")
            # print(component_registry)
            self._component_registry = self._connect(component_registry, "IUint256Component.json")
            self.id_to_component = dict()
            self.components = {x["name"]: self._get_component(x["name"]) for x in cfg.mud_components}
            self.component_types = {x["name"]: x["types"] for x in cfg.mud_components}
        # system_registry = self.world.call("systems()")
        # self._system_registry = self._connect(system_registry, "IUint256Component.json")
        self.systems = {x: self._get_system(x) for x in cfg.mud_systems}
        self.block = 0

    def _connect(self, address: str, abi_name: str) -> Web3Connector:
        return Web3Connector(address, self.config.w3_RPC, self.config.w3_WSRPC, self.private_key, self._get_abi(os.path.join(self.config.abi_dir, abi_name)))

    def _get_abi(self, path: str):
        abi = list()
        with open(path, 'r', encoding='utf-8') as abi_file:
            abi = json.loads(abi_file.read())["abi"]
        return json.dumps(abi, ensure_ascii=False)

    def _get_component(self, component: str) -> Web3Connector:
        component_id = eval(Web3.solidityKeccak(["string"], [f"component.{component}"]).hex())
        # print(component, component_id)
        address = self._component_registry.call(f"getEntitiesWithValue({component_id})")
        component_address = hex(address[0])
        if len(component_address) < 42:
            component_address = "0x"+"0"*(42-len(component_address))+component_address[2:]
        self.id_to_component[component_id] = component
        print("load Component:", component, component_address)
        return self._connect(component_address, f"{component}Component.json")

    def _get_system(self, system: str) -> Web3Connector:
        system_id = eval(Web3.solidityKeccak(["string"], [f"system.{system}"]).hex())
        system_address = self.world.call(f"getSystemAddress({system_id})")
        if len(system_address) < 42:
            system_address = "0x"+"0"*(42-len(system_address))+system_address[2:]
        # self.id_to_component[system_id] = f"system.{system}"
        print("load System:", system, system_address)
        return self._connect(system_address, f"{system}System.json")
    
    def send(self, system: str, param: str):
        """
        send("Move", "(1,1)")
        -> self.systems["Move"].send("executeTyped((1,1))")
        """
        self.systems[system].send(f"executeTyped({param})")
    
    def async_send(self, system: str, param: str):
        """
        send("Move", "(1,1)")
        -> self.systems["Move"].send("executeTyped((1,1))")
        """
        self.systems[system].send(f"executeTyped({param})")
    
    def has(self, component: str, entityId: int) -> bool:
        """
        components["Encounter"].call(f"has({mud.player})")
        """
        return self.components[component].call(f"has({entityId})")

    def set(self, component: str, entityId: int, value: str):
        """
        components["Encounter"].call(f"set({mud.player})")
        """
        return self.components[component].send(f"set({entityId},{value})")

    def remove(self, component: str, entityId: int):
        """
        components["Encounter"].call(f"remove({mud.player})")
        """
        return self.components[component].send(f"remove({entityId})")
    
    def getValue(self, component: str, entityId: Any) -> Any:
        """
        components["Position"].call(f"getValue({mud.player})")
        """
        return self.components[component].call(f"getValue({entityId})")
    
    def getEntitiesWithValue(self, component: str, value: str) -> List[Any]:
        """
        components["Position"].call(f"getEntitiesWithValue((1,1))")
        """
        return self.components[component].call(f"getEntitiesWithValue({value})")
    
    def getEntities(self, component: str) -> List[Any]:
        return self.components[component].call(f"getEntities()")
    
    def get_map(self) -> Dict[int, Dict[int, int]]:
        import base64
        w, h, ts = self.getValue("MapConfig", "")
        # dict<x, dict<y, t>>
        ret_dict = dict()
        counter = 0
        ts = base64.b16encode(ts).decode()
        while ts:
            t = int(ts[:2])
            ts = ts[2:]
            x = counter % w
            y = counter // w
            if x not in ret_dict:
                ret_dict[x] = dict()
            ret_dict[x][y] = t
            counter += 1
        return ret_dict
        # print(ret_dict)

    def get_equipments(self) -> Dict[int, Any]:
        ret_dict = dict()
        items = self.getEntities("ItemMetadata")
        # print(items)
        for item in items:
            boundary = self.getValue("Boundary2D", item)
            metadata = self.getValue("ItemMetadata", item)
            tx, ty, bx, by = boundary
            n, t, f = metadata
            coords = list()
            for x in range(tx, bx+1):
                for y in range(ty, by+1):
                    coord = (x, y)
                    coords.append(coord)
            ret_dict[item] = {
                "coords": coords,
                "name": n,
                "type": t,
                "functions": f
            }
        return ret_dict
    
    # def get_entity(self) -> 
    def get_events(self) -> List[Dict[str, Any]]:
        sets = self.world.searchEvent("ComponentValueSet", self.block)
        removes = self.world.searchEvent("ComponentValueRemoved", self.block)
        actions = list()
        while sets or removes:
            s = None
            s_block = None
            if sets:
                s = sets[0]
                s_block = s['blockNumber']
            r = None
            r_block = None
            if removes:
                r = removes[0]
                r_block = r['blockNumber']
            if (r_block is None or (s_block is not None and s_block <= r_block)) and s:
                # solve s
                address = self.id_to_component.get(s['args']['componentId'])
                if address:
                    info = {
                        "action": "set",
                        "component_address": s['args']['component'],
                        "component_name": address,
                        "entity": s['args']['entity'],
                        "data": self.parse_data(self.component_types[address], s['args']['data']),
                    }
                    actions.append(info)
                sets = sets[1:]
                self.block = s_block
                continue
            elif r:
                # solve r
                address = self.id_to_component.get(r['args']['componentId'])
                if address:
                    info = {
                        "action": "remove",
                        "component_address": r['args']['component'],
                        "component_name": address,
                        "entity": r['args']['entity'],
                        # "data": self.parse_data(self.component_types[address], r['args']['data']),
                    }
                    actions.append(info)
                removes = removes[1:]
                self.block = r_block
                continue
            # print(s)
            # print(r)
            break
        return actions
    
    def parse_data(self, types: List[str], data: bytes) -> Tuple[Any]:
        # print(types, data)
        return self.world.w3.eth.codec.decode_abi(types, data)

project_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))

targetSystem = "ChangeFogSeed"
privateKey = ""

privateKeyPath = os.path.join(project_dir, "private_key")
if os.path.exists(privateKeyPath):
    with open(privateKeyPath, "r", encoding="utf-8") as key_file:
        privateKey = key_file.read()

print("input:", sys.argv)

if len(sys.argv) > 1:
    targetSystem = sys.argv[1]
    if len(sys.argv) > 2:
        privateKey = sys.argv[2]

cfg = Config()
if not privateKey:
    raise ValueError("Private Key not appointed")
if not targetSystem:
    raise ValueError("target system not appointed")
if targetSystem.strip() not in cfg.mud_systems:
    raise ValueError("target system not valid")

mud = MUDConnector(privateKey.strip(), cfg)
component_map = {
    "ChangeResourceSeed": "ResourceDistribution",
    "ChangeSeed": "Terrain",
    "ChangeTreasureSeed": "TreasureDistribution",
    "ChangeFogSeed": "FogSeed",
}
print("target_component:", component_map[targetSystem])
print("before Change:", mud.getValue(component_map[targetSystem], f"{mud.singletonID}"))
mud.send(targetSystem, f"{random.randint(0, 999999999999999999)}")
import time
time.sleep(3)
print("after Change:", mud.getValue(component_map[targetSystem], f"{mud.singletonID}"))
