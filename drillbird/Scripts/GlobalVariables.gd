extends Node
signal playerAction()
signal PlayerIsDrillingTileChanged(answer:bool)
signal signal_IsPlayerInMenuChanged(inMenu:bool)
@export var DebugEnabled:bool=false

var save_file_path = "user://save/"
var save_file_name="DrillbirdPlayerSave.tres"

var MainSceneReferenceConnector:main_scene_reference_connector
var CreditsSceneReferenceConnector:credits_scene_reference_connector
var playerSpawnPos:Vector2
var eggState:int=0
var hasSeenIntroCutscene:bool=false
enum playerActions{DRILL,JUMP,DROPORE,INTERACT,SPAWNFLOWER}
var timeLastSaved:float=0
enum typeEnum{DRILL, INVENTORY, HEALTH, LIGHT}
enum playerStatusEnum {DIG,SLEEP,SHOP,NEWDAY,MENU}
signal playerStatusChanged
signal SetupComplete

var PlayerController:CharacterBody2D
var heartInEgg:bool=false
var ghostActive:bool=true
var displayPopups:bool=true
var totalOres:int=0
var oresFound:int=0

func ResetSaveData():
	var newData=abstract_savegame.new()
	ResourceSaver.save(newData,save_file_path+save_file_name)
	pass

func SetupPlayerReference(ctrl:CharacterBody2D):
	PlayerController=ctrl

func GetPlayerPosition()->Vector2:
	if PlayerController:
		return PlayerController.global_position
	else:
		push_error("Unassigned playercontroller in global variables")
		return Vector2(0,0)

var InitialSetup:bool=true:
	get:
		return InitialSetup
	set(value):
		
		if InitialSetup and !value:
			SetupComplete.emit()
		InitialSetup=value

var playerStatus:playerStatusEnum = playerStatusEnum.DIG:
	get:
		return playerStatus
	set(value):
		
		#If menu state changes to or from menu, let game know that pause state has changed
		if value==playerStatusEnum.MENU and playerStatus != playerStatusEnum.MENU:
			signal_IsPlayerInMenuChanged.emit(true)
		if value != playerStatusEnum.MENU and playerStatus == playerStatusEnum.MENU:
			signal_IsPlayerInMenuChanged.emit(false)
		
		playerStatus=value
		playerStatusChanged.emit()

signal playerMoneyChange
var playerMoney:int=0:
	get:
		return playerMoney
	set(value):
		playerMoney=value
		playerMoneyChange.emit()
		
var totalEGGsperienceGained:int=0 #set at startup to loaded in value
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

func GivePlayerMoney(value:int,fromOre:bool=true):
	if fromOre:
		totalEGGsperienceGained+=value
	playerMoney+=value

func AddXPFromKill(enemy:abstract_enemy):
	
	var min=1
	var max=2
	var amount=randi_range(min,max) 
	
	GivePlayerMoney(amount,false)
	return amount
	pass

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
	

	
