extends Node
enum typeEnum{DRILL, INVENTORY, HEALTH, LIGHT}

enum playerStatusEnum {DIG,SHOP}
var playerStatus = playerStatusEnum.DIG
var playerMoney:int=150

var upgradeLevel_light:int=0
var upgradeLevel_inventory:int=0
var upgradeLevel_health:int=0
var upgradeLevel_drill:int=0

func SetPlayerUpgradeLevel(upgradeType:typeEnum,_upgradeLevel:int):
	match upgradeType:
		typeEnum.DRILL:
			upgradeLevel_drill=_upgradeLevel
		typeEnum.INVENTORY:
			upgradeLevel_inventory=_upgradeLevel
		typeEnum.HEALTH:
			upgradeLevel_health=_upgradeLevel
		typeEnum.LIGHT:
			upgradeLevel_light=_upgradeLevel
	
	pass
	
func GetPlayerUpgradeLevel(upgradeType:typeEnum):
	match upgradeType:
		typeEnum.DRILL:
			return upgradeLevel_drill
		typeEnum.INVENTORY:
			return upgradeLevel_inventory
		typeEnum.HEALTH:
			return upgradeLevel_health
		typeEnum.LIGHT:
			return upgradeLevel_light
	
	pass
