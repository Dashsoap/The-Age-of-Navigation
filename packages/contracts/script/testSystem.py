import json, os, sys, random
from typing import Any, List, Dict, Tuple
import importlib
import traceback
import subprocess
import time

abs_path = os.path.dirname(os.path.realpath(__file__))
sys.path.append(os.path.join(abs_path, ".."))

dev = False
# "MoveSystem.py","ResourceSystem.py","TechSystem.py","TreasureSystem.py","AttackSystem.py","GuildSystem.py"
system_names = ["SimpleTestSystem.py"]

from web3 import Web3, HTTPProvider, WebsocketProvider
from eth_account import Account

class Config:
    """Main configuration."""
    def __init__(self):
        # Read data.
        self.world_address = "0xd8fD5d9E61396A91aB9D0960baf49d4cB54cb074"
        if os.path.exists(os.path.join(abs_path, "..", "world_address.txt")):
            with open(os.path.join(abs_path, "..", "world_address.txt")) as address_file:
                self.world_address = address_file.read().strip()
        self.w3_RPC = "http://localhost:8545" if dev else "https://follower.testnet-chain.linfra.xyz"
        self.w3_WSRPC = ""
        self.abi_dir = os.path.join(abs_path, "../abi")
        self.mud_components = list()
        self.mud_systems = list()
        if os.path.exists(os.path.join(abs_path, "..", "deploy.json")):
            with open(os.path.join(abs_path, "..", "deploy.json")) as address_file:
                part_info = json.loads(address_file.read())
                for component in part_info["components"]:
                    self.mud_components.append(component.rpartition("Component")[0])
                for system in part_info["systems"]:
                    self.mud_systems.append(system["name"].rpartition("System")[0])

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
        # try:
        # print(func)
        construct_txn = eval('self.contract.functions.{}'.format(func)).buildTransaction({
            'from': self.acct.address,
            'nonce': nonce,
            'gas': 30000000,
            'gasPrice': self.w3.toWei('0' if dev else '21', 'gwei'),
        })
        signed = self.acct.signTransaction(construct_txn)
        tx_hash = self.w3.eth.sendRawTransaction(signed.rawTransaction)
        tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
        print({"hash": tx_hash.hex(), "result": tx_receipt})
        return {"hash": tx_hash.hex(), "result": tx_receipt}
        # except Exception as e:
        #     print("func:", func)
        #     print(f"got Exception: {e.__class__}: {e}")
        #     traceback_str = traceback.format_tb(e.__traceback__)
        #     print("Traceback:")
        #     print(''.join(traceback_str))
        #     return
    
    def async_send(self, func):
        """send web3 request

        Args:
            func (str): _description_. 'funcName(params)'

        Returns:
            _type_: _description_
        """
        # while 1:
        nonce = self.w3.eth.getTransactionCount(self.acct.address)
        # print(action, nonce)
        # try:
            # print(func)
        construct_txn = eval('self.contract.functions.{}'.format(func)).buildTransaction({
            'from': self.acct.address,
            'nonce': nonce,
            'gas': 30000000,
            'gasPrice': self.w3.toWei('0' if dev else '21', 'gwei'),
        })
        signed = self.acct.signTransaction(construct_txn)
        tx_hash = self.w3.eth.sendRawTransaction(signed.rawTransaction)
        # tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
        # print(tx_receipt)
        # return {"hash": tx_hash.hex(), "result": tx_receipt}
            # except Exception as e:
            #     print("func:", func)
            #     print(f"got Exception: {e.__class__}: {e}")
            #     traceback_str = traceback.format_tb(e.__traceback__)
            #     print("Traceback:")
            #     print(''.join(traceback_str))
            #     nonce += 1
            #     if nonce >= 3:
            #         return

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
        # try:
        construct_txn = eval('self.contract.functions.{}'.format(func)).buildTransaction({
            'from': self.acct.address,
            'nonce': nonce,
            'gas': 30000000,
            'gasPrice': self.w3.toWei('0' if dev else '21', 'gwei'),
            'value': int(amount),
        })
        signed = self.acct.signTransaction(construct_txn)
        tx_hash = self.w3.eth.sendRawTransaction(signed.rawTransaction)
        tx_receipt = self.w3.eth.waitForTransactionReceipt(tx_hash)
        return {"hash": tx_hash.hex(), "result": tx_receipt}
        # except Exception as e:
        #     print("func:", func)
        #     print(f"got Exception: {e.__class__}: {e}")
        #     traceback_str = traceback.format_tb(e.__traceback__)
        #     print("Traceback:")
        #     print(''.join(traceback_str))
        #     # nonce += 1
        #     # if nonce >= 3:
        #         # break
        #     return

    def call(self, func1):
        # while 1:
        # nonce = self.w3.eth.getTransactionCount(self.acct.address)
        # try:
        func = 'self.contract.functions.{}'.format(func1)
        result = eval(func).call()
        return result
        # except Exception as e:
        #     print("func:", func1)
        #     print(f"got Exception: {e.__class__}: {e}")
        #     traceback_str = traceback.format_tb(e.__traceback__)
        #     print("Traceback:")
        #     print(''.join(traceback_str))
        #     return
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
        self.datatype_dict = {
            0: "bool",
            1: "int8",
            2: "int16",
            3: "int32",
            4: "int64",
            5: "int128",
            6: "int256",
            7: "int",
            8: "uint8",
            9: "uint16",
            10: "uint32",
            11: "uint64",
            12: "uint128",
            13: "uint256",
            14: "bytes",
            15: "string",
            16: "address",
            17: "bytes4",
            18: "bool[]",
            19: "int8[]",
            20: "int16[]",
            21: "int32[]",
            22: "int64[]",
            23: "int128[]",
            24: "int256[]",
            25: "int[]",
            26: "uint8[]",
            27: "uint16[]",
            28: "uint32[]",
            29: "uint64[]",
            30: "uint128[]",
            31: "uint256[]",
            32: "bytes[]",
            33: "string[]",
        }
        if loadComponents:
            component_registry = self.world.call("components()")
            # print(component_registry)
            self._component_registry = self._connect(component_registry, "IUint256Component.json")
            self.id_to_component = dict()
            self.component_types = dict()
            self.components = {x: self._get_component(x) for x in cfg.mud_components}
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
        print("loading component:", component, component_id)
        address = self._component_registry.call(f"getEntitiesWithValue({component_id})")
        component_address = hex(address[0])
        if len(component_address) < 42:
            component_address = "0x"+"0"*(42-len(component_address))+component_address[2:]
        self.id_to_component[component_id] = component
        print("load Component:", component, component_address)
        w3_client = self._connect(component_address, f"{component}Component.json")
        schema = w3_client.call("getSchema()")
        if isinstance(schema, str):
            schema = json.loads(schema)
        self.component_types[component] = [self.datatype_dict[x] for x in schema[1]]
        print("Component:", component, "getSchema:", schema)
        return w3_client

    def _get_system(self, system: str) -> Web3Connector:
        system_id = eval(Web3.solidityKeccak(["string"], [f"system.{system}"]).hex())
        print("loading system:", system, system_id)
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
        return(self.systems[system].send(f"executeTyped({param})"))
    
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
    
    def getSchema(self, component: str) -> Any:
        """
        components["Position"].call(f"getSchema()")
        """
        return self.components[component].call(f"getSchema()")
    
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

class Actors(object):
    def __init__(self, pks: List[str], cfg: Config) -> None:
        self.fogHashToCoord = {
            17003822395431833919614783247929920144935458814324030459644824369382430169450: (12, 4),
            12773467461814680623560896265081485691237793202333668868183619086335957962744: (12, 5),
            7785378244855662793379740421363028623283683143249708776303452909102939252391: (13, 3),
            17960145934645911381904120820539289306682005468741135871524991943190207243035: (13, 4),
            6548174236596742820902339565391718630727264115530773170571288163083533194409: (13, 5),
            19121410463005164307149571097624914303252356622127636921228827670930113884904: (13, 6),
            8972191127294552924442836583801592041567693831137116523236218356960792026093: (14, 4),
            9250721396394427503954614595573205862894703497967780899290082465753407989677: (14, 5),
        }
        self.coordToFogHash = {v: k for k, v in self.fogHashToCoord.items()}
        self.fogHashToCoordVerify = {
            17003822395431833919614783247929920144935458814324030459644824369382430169450: "(8098379986960192774499085428746090268559066922778336447500747954225535591495,17003822395431833919614783247929920144935458814324030459644824369382430169450,44444,50,100,[17668104884186011860528811521051526678273847896491166426265678833901684431392,16808875012345607113888989010755965673670048517633348688692670059522790858402],[[12191824948961053819677590272219030801509840715197433204124697823238888762061,20990120993740705913295568227964696532553576680009898908901319152837358686550],[14176803890778134137149456030033658306648432650093119118746663120907154581515,3665330124640650382888234115391327336655558229847966214750319422055737997130]],[14879652048427495656526724466963049021501473174227456880190486332655053365854,4015101512826413390708165608865905437740078998946936147677184980211036470631])",
            12773467461814680623560896265081485691237793202333668868183619086335957962744: "(15584632865826866064806876280572923107545782282228097748224480891508776078800,12773467461814680623560896265081485691237793202333668868183619086335957962744,44444,50,100,[10669074083116656577277932400932746588353184414677152040815421874661359044079,6248756393058410163953399812037441457042915780534454578428195049309005639804],[[605227614386211251970074938111146342120407479361403987666843768592152703139,15294176651703019556875272862958619485018234915285633467174864850021274508672],[10875508032334785400791565082825279172433248976632641404448359557972663816186,5696852436212647975250258005837014485016384347568319778536530095371705578517]],[5043307450713121371145797136413351730013047188348464272523084509366836241876,17125820054359199035751280707209824333281116650942461020923086735078474724026])",
            7785378244855662793379740421363028623283683143249708776303452909102939252391: "(1919073696119914747956734921900413789959993717110880749594278436983681194175,7785378244855662793379740421363028623283683143249708776303452909102939252391,44444,50,100,[12974530924546681950120051876251532140578639942617558623936117436372754161747,5843717839895471672907986464180713303527041518166516178451629160298991574809],[[9518074340654100261814702862765208851720290555913143484646293271244166249316,5874236458087645385562006265643185091573099802259331884003875294038196151112],[7563433131586824839785239021808815652676225425955855863606945210185779144074,15110919698260361694225831642183729091328770818068063557920355198121793564912]],[19447124622017177408597977155061311539127153949998946268793687499548329920891,11665434760795737136836539458435606328324817853778001714612886230483924313332])",
            17960145934645911381904120820539289306682005468741135871524991943190207243035: "(9109964923784555505756535058688411810040322501253582306549209238152275236278,17960145934645911381904120820539289306682005468741135871524991943190207243035,44444,50,100,[11545058738791041048148866707486501553064611311027836012526458855909828217792,769048559802151633409970124002020314859593400121373629549930118547170639957],[[1834892202282699050156426325954665871724285722959812270450404805332875020175,13197626195817488709696922247122480520884173138250339464462968464499190010547],[10785677637200435937934334632528830911350130350785468995169400784405361337041,2746220510699274693107305808601930999444291544003094720973166543050357219826]],[20120797246243140230614063592369964671766707195150378841362272338785096709639,11994921864514687561550453528246956356842585798715404980656445821323064953362])",
            6548174236596742820902339565391718630727264115530773170571288163083533194409: "(1760186212227967992807915426465403124144027458072790513337346726966364932656,6548174236596742820902339565391718630727264115530773170571288163083533194409,44444,50,100,[18315195830153514173957459591247365534686505265256896180601764306482185357848,9837443574098708095433265505719787510533876273711099109295380962192355518840],[[16971294361398987622151664345797255544350087743338791416055322972856213615511,8211788504159238392914232455320003971397556123681623133522984908755417584162],[21238063922653930397689851004383036612943458938373256197740186383689811673580,8942659697979896384629170922334665263825981287818335375584143846650010130489]],[21015796391879540323264588918548025658319789680321438424646429225087263043559,12952455836047253816153081416109929961688642479948739785579401162973098887181])",
            19121410463005164307149571097624914303252356622127636921228827670930113884904: "(12984581649096013937988104903047130734481114505081628947361905824505995737972,19121410463005164307149571097624914303252356622127636921228827670930113884904,44444,50,100,[13959383008486576787005148502420107894322740480590301567612454426363453291757,3456537954977885684555400650619319249715238611540143119513870253678653682824],[[1849436173237439170267117455753453423630692603358665724387291158182681677599,18383527625118881711473640842887346738068791718319343843067611440234084988703],[10005786784695866964555798610077203624384627715166313215858561261885986437243,16632736367316934407164741271617677384799330247780253889038702658094839938131]],[9611003654723936485892911660789145503488910062184451256049245541774307518829,5616930220716591708411930780498339910674350924594929951933992286820307041585])",
            8972191127294552924442836583801592041567693831137116523236218356960792026093: "(9594941503458407259128947502076508160380507453889476465197504201095945299164,8972191127294552924442836583801592041567693831137116523236218356960792026093,44444,50,100,[11866340586861895397234094299851243608971572872793735387953980459972416662489,9491801498332835642345497643024485405656318971394624894063173345624819887773],[[9547559528691540565878870947004803310818605958382873759630230466532217095118,12822763055899587787542961927828176190709712115069377472960029568555243930558],[13890159953356260770252318656214745128558085068848785492679508653457645283494,4899085090612708947140159719799088179065950579218056954095254461766861234936]],[17053045556891347922878880743915504670893299200872739848676269503705934385967,12833897757628538518655465842576306536317373424245649538808725308143849088674])",
            9250721396394427503954614595573205862894703497967780899290082465753407989677: "(5232039058361992336026683407352978853480586323682997417625642417280953631525,9250721396394427503954614595573205862894703497967780899290082465753407989677,44444,50,100,[7556650603894277203451149744016130985153746199007334113114367757815411020928,379584158646933073456925288171940729190614621377546563136715591430658796904],[[10596514581027993983722163062697271212286316927857949279832626872967199928600,21244423078635423879570589728999820763338683131616531967391109336649725294730],[3259133450318604620037064832831956470521929151411494664308876213867355263369,12036297747798522059924124347034940802675941521952174656233248744477518778684]],[7941699198031820199376873997631006742340386555461893745416632243955315221017,19489296627474919239117037141162355962588524830396931094842164620451072028570])",
        }
        self.actors = [MUDConnector(pk.strip(), cfg) for pk in pks]
        self.cfg = cfg
    
    def get_verify(self, x, y):
        return self.fogHashToCoordVerify[self.coordToFogHash[(x,y)]]
    
    def add_token(self, actor: MUDConnector, times=1):
        address = actor.wallet
        cmd = f"cd {project_dir} && pnpm mud faucet --address {address}"
        for _ in range(times):
            print(subprocess.getstatusoutput(cmd))
            time.sleep(3)

    def new_actor(self) -> None:
        new_pk = new_account()
        actor = MUDConnector(new_pk.strip(), self.cfg)
        self.add_token(actor)
        actor.send("JoinGamev2", "(17960145934645911381904120820539289306682005468741135871524991943190207243035,50,100,44444,[3820194968430044456454941973887732017356168706216627185920524511901930750102,11099047668422372216720557334876211857843609978627482400630927880463806824153],[[7020507749423474048980680849320860000118860335804960564696278038805422054495,1206903676815660188318774244230686875065529969249251058211537323514584642180],[9292924916184082238365883206429929723696057654404239577700335108393747431962,5229100533157015649664140751427566135975653886396339902083720019836229540845]],[2083381582530960818151654413817355660822304127069123470689387870983893063282,1101078986424306573266932869325642677486077784703591845437414741998352202719])")
        self.actors.append(actor)

project_dir = os.path.dirname(os.path.dirname(os.path.realpath(__file__)))
if __name__ == "__main__":
    # targetSystem = "ChangeFogSeed"
    privateKey = ""

    privateKeyPath = os.path.join(project_dir, "private_key")
    if os.path.exists(privateKeyPath):
        with open(privateKeyPath, "r", encoding="utf-8") as key_file:
            privateKey = key_file.read()

    if not privateKey:
        raise ValueError("Private Key not appointed")

    cfg = Config()
    actors = Actors([privateKey], cfg)
    actors.add_token(actors.actors[0], 10)

    def test(module_path):
        # Import module.
        module = importlib.import_module(module_path)
        # Get class.
        cls = getattr(module, module_path.split('.')[-1])
        # Create the command object.
        unit = cls()
        # Execute command.
        unit.execute_test(actors)

    # systems = os.listdir(os.path.join(abs_path, "systems"))
    for system_name in system_names:
        if system_name.endswith("System.py") and system_name != "System.py":
            test(f'script.systems.{system_name.rpartition(".")[0]}')
