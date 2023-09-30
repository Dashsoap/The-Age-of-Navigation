from script.systems.System import System
from script.testSystem import Actors

class MoveSystem(System):
    def __init__(self) -> None:
        self.name = "MoveSystem"
        self.components = [
            "HiddenPosition",
            "Warship",
            "HP",
            "GoldAmount",
            "MoveCooldown",
            "Player"
        ]
        self.systems = [
            "JoinGamev2",
            "Movev2",
        ]
        self.system_input = {
            "JoinGamev2": {
                "formatter": "({coordHash},{width},{height},{seed},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}])",
                "params": [
                    "{coordHash}",
                    "{width}",
                    "{height}",
                    "{seed}",
                    "{a[0]}",
                    "{a[1]}",
                    "{b[0][0]}",
                    "{b[0][1]}",
                    "{b[1][0]}",
                    "{b[1][1]}",
                    "{c[0]}",
                    "{c[1]}",
                ]
            },
            "Movev2": {
                "formatter": "({coordHash},{width},{height},{seed},{oldHash},{oldSeed},{distance},[{a[0]},{a[1]}],[[{b[0][0]},{b[0][1]}],[{b[1][0]},{b[1][1]}]],[{c[0]},{c[1]}])",
                "params": [
                    "{coordHash}",
                    "{width}",
                    "{height}",
                    "{seed}",
                    "{oldHash}",
                    "{oldSeed}",
                    "{distance}",
                    "{a[0]}",
                    "{a[1]}",
                    "{b[0][0]}",
                    "{b[0][1]}",
                    "{b[1][0]}",
                    "{b[1][1]}",
                    "{c[0]}",
                    "{c[1]}",
                ]
            },
        }

    def execute_test(self, actors: Actors):
        basic_actor = actors.actors[0]
        # join game
        has_player = basic_actor.has("Player", f"{basic_actor.player}")
        self.log("check if player inited")
        self.log(has_player)
        self.log("join game")
        result = basic_actor.send("JoinGamev2", "(17960145934645911381904120820539289306682005468741135871524991943190207243035,50,100,44444,[3820194968430044456454941973887732017356168706216627185920524511901930750102,11099047668422372216720557334876211857843609978627482400630927880463806824153],[[7020507749423474048980680849320860000118860335804960564696278038805422054495,1206903676815660188318774244230686875065529969249251058211537323514584642180],[9292924916184082238365883206429929723696057654404239577700335108393747431962,5229100533157015649664140751427566135975653886396339902083720019836229540845]],[2083381582530960818151654413817355660822304127069123470689387870983893063282,1101078986424306573266932869325642677486077784703591845437414741998352202719])")
        self.log(result['hash'])
        has_player = basic_actor.has("Player", f"{basic_actor.player}")
        self.log("check if player inited after join game")
        self.log(has_player)
        hidden_position = basic_actor.getValue("HiddenPosition", f"{basic_actor.player}")
        self.log("position after join game expected to be `17960145934645911381904120820539289306682005468741135871524991943190207243035`")
        self.log(hidden_position)
        self.log("move to 6548174236596742820902339565391718630727264115530773170571288163083533194409")
        result = basic_actor.send("Movev2", "(6548174236596742820902339565391718630727264115530773170571288163083533194409,50,100,44444,17960145934645911381904120820539289306682005468741135871524991943190207243035,44444,1,[13403195932017686678979301509786578800286381577544626100992311337312720592147,14936712468012401608715733867659792941197213909554451718617151826781147451565],[[4089517827434488218068382706401500407231846730597853623933072700590303037365,14938884734817083967591358965691501514973759709958177604015474822749982851282],[20942797325910327981973637961582599143840384118655356438442626292579337923967,20823711534344044951823921340308856426661483118684065570263682700121179464678]],[16423295597895050545232624681201154527339560596379586428347862922311615120517,5207002118403052196648954518618624827111170556741939650777546627638928668184])")
        self.log(result['hash'])
        hidden_position = basic_actor.getValue("HiddenPosition", f"{basic_actor.player}")
        self.log("position after move expect to be `6548174236596742820902339565391718630727264115530773170571288163083533194409`")
        self.log(hidden_position)
        return
