extends Node
enum typeEnum{DRILL, INVENTORY, HEALTH, LIGHT}

enum playerStatusEnum {DIG,SHOP}
var playerStatus = playerStatusEnum.DIG
var playerMoney:int=150

var upgradeLevel_light:int=0
var upgradeLevel_inventory:int=0
var upgradeLevel_health:int=0
var upgradeLevel_drill:int=0

func SetPlayerUpgradeLevel(upgradeType:typeEnum,upgradeLevel:int):
	"""
	match upgradeType:
		upgradeType.DRILL:
			pass
	"""
	pass
