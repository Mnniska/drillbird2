extends Node
enum typeEnum{DRILL, INVENTORY, HEALTH, LIGHT}
enum playerStatusEnum {DIG,SLEEP,SHOP,NEWDAY}
signal playerStatusChanged
var playerStatus:playerStatusEnum = playerStatusEnum.DIG:
	get:
		return playerStatus
	set(value):
		playerStatus=value
		playerStatusChanged.emit()

var playerMoney:int=0
var upgradeLevel_health:int=0
var upgradeLevel_drill:int=0

#LIGHT
signal playerLightStatusChange
enum playerLightStatusEnum{LIT_BYPLAYER,LIT_EXTERNALLY,DARK}
var playerLightStatus:playerLightStatusEnum=playerLightStatusEnum.LIT_BYPLAYER:
	get:
		return playerLightStatus
	set(value):
		playerLightStatus=value
		playerLightStatusChange.emit()
		

signal lightSourceChange
var amountOfLightsourcesPlayerIsIn:int=0:
	get:
		return amountOfLightsourcesPlayerIsIn
	set(value):
		amountOfLightsourcesPlayerIsIn=value	
		lightSourceChange.emit()

signal upgradeChange_Light
var upgradeLevel_light:int=0:
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
