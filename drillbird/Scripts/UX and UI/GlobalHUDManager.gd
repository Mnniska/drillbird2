extends CanvasLayer

@onready var HUD_lightBulbManager=$topUI/LightHandler
@onready var HUD_healthManager=$topUI/HealthUIHandler
@onready var HUD_cashText=$topUI/CashHolder/cashNumber
@onready var HUD_InventoryManager=$bottomUI/InventoryHandler
@onready var MainMenu=$MainMenu

enum menuStates{MAIN,PAUSE,OPTIONS,PLAY}
var state:menuStates=menuStates.MAIN

@onready var ui_top=$topUI
var topUIVisiblePos:Vector2
@onready var ui_bottom=$bottomUI
var bottomUIVisiblePos:Vector2

#HUD manager vars
@export var showHud:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	topUIVisiblePos=ui_top.global_position
	bottomUIVisiblePos=ui_bottom.global_position
	
	GlobalVariables.SetupComplete.connect(SetupComplete)
	
	pass # Replace with function body.

func SetupComplete():
	SetState(menuStates.MAIN)


func GetLightManager():
	return HUD_lightBulbManager

func SetHudVisible(_show:bool):

	showHud=_show

	if showHud:
		ui_top.global_position=topUIVisiblePos
		ui_bottom.global_position=bottomUIVisiblePos
	else:
		var topOffset:Vector2=Vector2(0,-16)
		var bottomOffset:Vector2=Vector2(0,24)
		ui_top.global_position=topUIVisiblePos+topOffset
		ui_bottom.global_position=bottomUIVisiblePos+bottomOffset
		
	
	pass

func SetState(_state:menuStates):
	
	state=_state
	
	
	match state:
		menuStates.MAIN:
			SetHudVisible(false)
			MainMenu.show()
			GlobalVariables.PlayerController.SetPlayerHidden(true)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.MENU

			pass
		menuStates.PAUSE:
			MainMenu.hide()

			pass
		menuStates.OPTIONS:
			MainMenu.hide()

			pass
		menuStates.PLAY:
			SetHudVisible(true)
			GlobalVariables.PlayerController.SetPlayerHidden(false)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG

			MainMenu.hide()

			
			pass


func _on_main_menu_new_game() -> void:
	SetState(menuStates.PLAY)

	pass # Replace with function body.
