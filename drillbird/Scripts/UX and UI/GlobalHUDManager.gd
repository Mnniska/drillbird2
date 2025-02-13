extends CanvasLayer

@onready var HUD_lightBulbManager=$topUI/LightHandler
@onready var HUD_healthManager=$topUI/HealthUIHandler
@onready var HUD_cashText=$topUI/CashHolder/cashNumber
@onready var HUD_InventoryManager=$bottomUI/InventoryHandler
@onready var MainMenu=$MainMenu

enum menuStates{MAIN,PAUSE,OPTIONS,PLAY}
var state:menuStates=menuStates.MAIN



#HUD manager vars
@export var showHud:bool=false

@export var HudLerpTime=0.5
var lerpCounter=0
var isLerping:bool=false

#Variables for lerping the top and bottom UI, super tiny detail
@onready var ui_top=$topUI
@onready var ui_bottom=$bottomUI
var pos_top_visible:Vector2
var pos_top_hidden:Vector2
var pos_bottom_visible:Vector2
var pos_bottom_hidden:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pos_top_visible=$topUI.global_position
	pos_top_hidden=pos_top_visible+Vector2(0,-24)
	pos_bottom_visible=$bottomUI.global_position
	pos_bottom_hidden=pos_bottom_visible+Vector2(0,24)
	
	GlobalVariables.SetupComplete.connect(SetupComplete)
	
	pass # Replace with function body.

func SetupComplete():
	
	var hasSaveGame= !GlobalVariables.currentDay==1
	StartMainMenu(hasSaveGame)


func StartMainMenu(hasSaveGame:bool):
	
	if hasSaveGame:
		GlobalVariables.MainSceneReferenceConnector.ref_home.MainMenu_SetupSleepIdle()
	SetState(menuStates.MAIN)	
	pass

func GetLightManager():
	return HUD_lightBulbManager

func SetHudVisible(_show:bool):

	showHud=_show
	isLerping=true
	lerpCounter=0
		
	
func _process(delta: float) -> void:
	
	if isLerping:
		lerpCounter+=delta
		var progress=lerpCounter/HudLerpTime

		if showHud:		
			ui_top.global_position=lerp(pos_top_hidden,pos_top_visible,progress)
			ui_bottom.global_position=lerp(pos_bottom_hidden,pos_bottom_visible,progress)
		else:
			ui_top.global_position=lerp(pos_top_visible,pos_top_hidden,progress)
			ui_bottom.global_position=lerp(pos_bottom_visible,pos_bottom_hidden,progress)
		
		if lerpCounter>=HudLerpTime:
			isLerping=false
			
func SetState(_state:menuStates):
	
	state=_state
	
	
	match state:
		menuStates.MAIN:
			SetHudVisible(false)
			MainMenu.show()
			MainMenu.GenerateMainMenu()
			GlobalVariables.PlayerController.SetPlayerHidden(true)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.MENU

			pass
		menuStates.PAUSE:
			MainMenu.Deactivate()

			pass
		menuStates.OPTIONS:
			MainMenu.Deactivate()

			pass
		menuStates.PLAY:
			SetHudVisible(true)
			GlobalVariables.PlayerController.SetPlayerHidden(false)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
			MainMenu.Deactivate()
			
			#If player has saved game, wake up on egg
			if GlobalVariables.currentDay>1:
				GlobalVariables.MainSceneReferenceConnector.ref_home.WakeUp(false)


			
			pass


func _on_main_menu_new_game() -> void:
	SetState(menuStates.PLAY)

	pass # Replace with function body.
