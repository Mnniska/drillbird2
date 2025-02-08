extends Node
signal playerAction()
signal PlayerIsDrillingTileChanged(answer:bool)
var MainSceneReferenceConnector:main_scene_reference_connector
var playerSpawnPos:Vector2

enum playerActions{DRILL,JUMP,DROPORE,INTERACT}

enum typeEnum{DRILL, INVENTORY, HEALTH, LIGHT}
enum playerStatusEnum {DIG,SLEEP,SHOP,NEWDAY,MENU}
signal playerStatusChanged
signal SetupComplete

var PlayerController:CharacterBody2D
func SetupPlayerReference(ctrl:CharacterBody2D):
	PlayerController=ctrl

var InitialSetup:bool=true:
	get:
		return InitialSetup
	set(value):
		InitialSetup=value
		SetupComplete.emit()

var playerStatus:playerStatusEnum = playerStatusEnum.DIG:
	get:
		return playerStatus
	set(value):
		playerStatus=value
		playerStatusChanged.emit()

signal playerMoneyChange
var playerMoney:int=0:
	get:
		return playerMoney
	set(value):
		playerMoney=value
		playerMoneyChange.emit()
		
var totalExperienceGained:int=0 #set at startup to loaded in value
var playerHealth:int=2 #This should be loaded in depending on current upgrade lvl in future

var currentDay:int=1


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


#-----UPGRADES-----
#The save game will only modify this file - the rest of the project will listen to it
signal upgradeChange_Health
var upgradeLevel_health:int=0:
	get:
		return upgradeLevel_health
	set(value):
		upgradeLevel_health=value
		upgradeChange_Health.emit()

signal upgradeChange_Drill
var upgradeLevel_drill:int=0:
	get:
		return upgradeLevel_drill
	set(value):
		upgradeLevel_drill=value
		upgradeChange_Drill.emit()

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

func GivePlayerMoney(value:int):
	totalExperienceGained+=value
	playerMoney+=value

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
	

	
