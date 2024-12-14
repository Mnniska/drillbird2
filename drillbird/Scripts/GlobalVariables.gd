extends Node
enum typeEnum{DRILL, INVENTORY, HEALTH, LIGHT}

enum playerStatusEnum {DIG,SHOP,NEWDAY}
var playerStatus = playerStatusEnum.DIG
var playerMoney:int=0

signal upgradeChange_Light
var upgradeLevel_light:int=4:
	get:
		return upgradeLevel_light
	set(value):
		upgradeLevel_light=value
		upgradeChange_Light.emit()
		pass
		
signal upgradeChange_Inventory
var upgradeLevel_inventory:int=0:
	get:
		return upgradeLevel_inventory
	set(value):
		upgradeLevel_inventory=value
		upgradeChange_Inventory.emit()


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
