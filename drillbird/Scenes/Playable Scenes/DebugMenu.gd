extends Node2D
@export var menu:Array[abstract_debugMenuOption]
var currentMenu:Array[abstract_debugMenuOption]
@onready var textshown = $RichTextLabel
@onready var OreRegions=$"../../TilemapOres/OreRegions"
var textstring:String=""
var currentSelection:int=0
var Active:bool=false
signal DebugActionRequested(action:String)
var mainMenuShowing:bool=false
var playerHidden:bool=false
@export var oreToSpawn:PackedScene
@export var oreTypeToAssignSpawnedOre:abstract_ore
@export var canEnableDebug:bool=true

@export var finalHeartOre:abstract_ore
var hudHidden:bool=false
var debugAvailable:bool=true

var debugUnlockCount:int=0
var debugUnlockTimeoutTimer:float=0.5
var debugUnlockTimeourCounter:float=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentMenu=menu
	debugAvailable = GlobalVariables.DebugEnabled
		
	pass # Replace with function body.

func SelectionLogic():
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	if !debugAvailable:
		
		if Input.is_action_just_pressed("debug_tab") and canEnableDebug:
			debugUnlockCount+=1
			debugUnlockTimeourCounter=debugUnlockTimeoutTimer
			if debugUnlockCount>=10:
				GlobalVariables.DebugEnabled=!GlobalVariables.DebugEnabled
				debugAvailable=GlobalVariables.DebugEnabled
				debugUnlockCount=0
				SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_WAKEUP)
		
		if debugUnlockTimeourCounter>0:
			debugUnlockTimeourCounter-=delta
		else:
			debugUnlockCount=0
		
		#cannot access debug features if it is not turned on
		return
	
	if Input.is_action_just_pressed("debug_2"):
		if !Active:
			Active=true
			show()
			GenerateMenu()
		else:
			CloseDebugMenu()
	
	if !Active:
		return
	
	
	var shouldUpdate:bool=false
	
	if Input.is_action_just_pressed("jump"):
		SelectMenuItem()
	
	if Input.is_action_just_pressed("left"):
		Backout()
	
	if Input.is_action_just_pressed("down"):
		currentSelection+=1
		shouldUpdate=true
		pass
	
	if Input.is_action_just_pressed("up"):
		currentSelection-=1
		shouldUpdate=true
		pass
	
	if currentSelection>currentMenu.size()-1:
		currentSelection=0
	
	if currentSelection<0:
		currentSelection=currentMenu.size()-1
	
	if shouldUpdate:
		GenerateMenu()
	pass

func SelectMenuItem():
	
	var selected=currentMenu[currentSelection]
	if !selected.isAction:
		currentMenu=selected.options
		GenerateMenu()
	else:
		ExecuteAction(currentMenu[currentSelection].name)
		pass
	
	pass

func Backout():
	if currentMenu==menu:
		pass
	else:
		currentMenu=menu
		GenerateMenu()
	
	
	pass

func CloseDebugMenu():
	hide()
	Active=false
	pass

func GenerateMenu():
	
	currentSelection=clampi(currentSelection,0,currentMenu.size()-1)
	
	var index:int=0
	textstring=""
	for n in currentMenu:
		
		var selected:String=""
		if currentSelection==index:
			selected=" <<"
		
		textstring+=currentMenu[index].name+selected+"\n"
		index+=1
		pass
	
	textshown.text=textstring
	
	pass
	
func ExecuteAction(action:String):
	DebugActionRequested.emit(action)
	
	var inventory= HUD.HUD_InventoryManager
	var health = HUD.HUD_healthManager
	var light = HUD.HUD_lightBulbManager

	
	match action:
		"inventory_upgrade_add":
			var invEnum=GlobalVariables.typeEnum.INVENTORY
			GlobalVariables.SetPlayerUpgradeLevel(invEnum,GlobalVariables.GetPlayerUpgradeLevel(invEnum)+1)
			inventory.SetupInventorySize()
			pass
		"inventory_upgrade_remove":
			var invEnum=GlobalVariables.typeEnum.INVENTORY
			if GlobalVariables.GetPlayerUpgradeLevel(invEnum)>0:
				
				GlobalVariables.SetPlayerUpgradeLevel(invEnum,GlobalVariables.GetPlayerUpgradeLevel(invEnum)-1)
				inventory.SetupInventorySize()
		"drill_upgrade_add":
			var drillEnum=GlobalVariables.typeEnum.DRILL
			var target:int=GlobalVariables.GetPlayerUpgradeLevel(drillEnum)+1
			GlobalVariables.SetPlayerUpgradeLevel(drillEnum,target)
		"drill_upgrade_remove":
			var drillEnum=GlobalVariables.typeEnum.DRILL
			if GlobalVariables.GetPlayerUpgradeLevel(drillEnum)>0:			
				var target:int=GlobalVariables.GetPlayerUpgradeLevel(drillEnum)+-1
				
				GlobalVariables.SetPlayerUpgradeLevel(drillEnum,target)
		"health_refill":
			health.RefillHealth()
			pass
		"health_hurt":
			health.TakeDamage(1)
			pass
		"health_kill":
			health.TakeDamage(20)
			pass
		"health_upgrade":
			var healthE=GlobalVariables.typeEnum.HEALTH
			var upgrade=GlobalVariables.GetPlayerUpgradeLevel(healthE)+1
			GlobalVariables.SetPlayerUpgradeLevel(healthE,upgrade)
			health.UpgradeHealth()
		"light_refill":
			light.RefillLight()
		"light_deplete":
			light.DepleteLight()
		
		"light_upgrade_add":
			var lightE=GlobalVariables.typeEnum.LIGHT
			var upgrade=GlobalVariables.GetPlayerUpgradeLevel(lightE)+1
			GlobalVariables.SetPlayerUpgradeLevel(lightE,upgrade)
			
		"save_game":
			$"../..".SaveGame()
		"reset_save_data":
			$"../..".ResetSaveData()
		
		"reset_save_data_enemies_and_tiles":
			$"../..".ResetSaveData(true)
		
		"toggleMenu":
			mainMenuShowing=!mainMenuShowing
			var mainmenu=HUD.MainMenu
		
			if mainMenuShowing:
				mainmenu.show()
				HUD.SetHudVisible(false)
			else:
				mainmenu.hide()
				HUD.SetHudVisible(true)
		"togglePlayerHidden":
			playerHidden=!playerHidden
			
			if playerHidden:
				$"../../Player".hide()
			else:
				$"../../Player".show()
				
		"ToggleHUDHidden":
			hudHidden=!hudHidden
			HUD.SetHudVisible(hudHidden)			
			
		"spawnOre":
			var node=oreToSpawn.instantiate()
			node.transform.origin=get_parent().to_local(GlobalVariables.MainSceneReferenceConnector.player.global_position+Vector2(16,-16)) 
			node.oreType=oreTypeToAssignSpawnedOre
			get_parent().add_child(node)
			
		"spawnFinalHeart":
			var node=oreToSpawn.instantiate()
			node.transform.origin=get_parent().to_local(GlobalVariables.MainSceneReferenceConnector.player.global_position+Vector2(16,-16)) 
			node.oreType=finalHeartOre
			get_parent().add_child(node)
		"CalculateOreRegion0":
			OreRegions.GetValueOfOresForRegion(0)
			pass
		"CalculateOreRegion1":
			OreRegions.GetValueOfOresForRegion(1)			
			pass
		
		"CalculateOreRegion2":
			OreRegions.GetValueOfOresForRegion(2)
			pass
		"CalculateOreRegion3":
			OreRegions.GetValueOfOresForRegion(3)
			pass
		"CalculateOreRegion4":
			OreRegions.GetValueOfOresForRegion(4)
			pass
			
		"ToggleDisplayPopups":
			GlobalVariables.displayPopups=!GlobalVariables.displayPopups
			pass
		"Go_to_credits":
			HUD.SetSceneState(HUD.sceneStates.CREDITS)
		
		"GetAmountOfOres":
			print_debug("Amount of ores: "+str(OreRegions.GetAmountOfOreTiles()))
			#GlobalVariables.MainSceneReferenceConnector.ref_h
			
		"test_achievement":
			SteamHandler.TryUnlockAchievement("ACH_TEST")
	pass
