extends Node2D
@export var menu:Array[abstract_debugMenuOption]
var currentMenu:Array[abstract_debugMenuOption]
@onready var textshown = $RichTextLabel
var textstring:String=""
var currentSelection:int=0
var Active:bool=false
signal DebugActionRequested(action:String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentMenu=menu

	pass # Replace with function body.

func SelectionLogic():
	
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
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
	
	match action:
		"inventory_upgrade_add":
			var invEnum=GlobalVariables.typeEnum.INVENTORY
			GlobalVariables.SetPlayerUpgradeLevel(invEnum,GlobalVariables.GetPlayerUpgradeLevel(invEnum)+1)
			$"../InventoryHandler".UpdateInventoryPositions()
			pass
		"inventory_upgrade_remove":
			var invEnum=GlobalVariables.typeEnum.INVENTORY
			if GlobalVariables.GetPlayerUpgradeLevel(invEnum)>0:
				
				GlobalVariables.SetPlayerUpgradeLevel(invEnum,GlobalVariables.GetPlayerUpgradeLevel(invEnum)-1)
				$"../InventoryHandler".UpdateInventoryPositions()
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
			$"../HealthUIHandler".RefillHealth()
			pass
		"health_hurt":
			$"../HealthUIHandler".TakeDamage(1)
			pass
		"health_kill":
			$"../HealthUIHandler".TakeDamage(20)
			pass
		"health_upgrade":
			var healthE=GlobalVariables.typeEnum.HEALTH
			var upgrade=GlobalVariables.GetPlayerUpgradeLevel(healthE)+1
			GlobalVariables.SetPlayerUpgradeLevel(healthE,upgrade)
			$"../HealthUIHandler".UpgradeHealth()
		"light_refill":
			$"../LightHandler".RefillLight()
		"light_deplete":
			$"../LightHandler".DepleteLight()
		
		"light_upgrade_add":
			var lightE=GlobalVariables.typeEnum.LIGHT
			var upgrade=GlobalVariables.GetPlayerUpgradeLevel(lightE)+1
			GlobalVariables.SetPlayerUpgradeLevel(lightE,upgrade)
			
		"save_game":
			$"../..".SaveGame()
		"reset_save_data":
			$"../..".ResetSaveData()

			
	pass
