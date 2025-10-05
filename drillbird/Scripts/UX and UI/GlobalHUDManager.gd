extends CanvasLayer

@export var version:String

@onready var HUD_lightBulbManager=$topUI/LightHandler
@onready var HUD_healthManager=$topUI/HealthUIHandler
@onready var HUD_cashText=$topUI/CashHolder/cashNumber
@onready var HUD_InventoryManager=%InventoryHandler
@onready var MainMenu=$MainMenu
@onready var OptionsMenu=$Options
@onready var PauseMenu=$PAUSE
@onready var SpeedrunTimer=$SpeedrunTimer

signal signal_menuStateChanged
enum menuStates{MAIN,PAUSE,OPTIONS,PLAY,CREDITS}
var state:menuStates=menuStates.MAIN:
	get: return state
	set(new_state):
		state=new_state
		signal_menuStateChanged.emit(new_state)
var previousMenuState:menuStates

enum sceneStates{MAIN,CREDITS}
var sceneState:sceneStates=sceneStates.MAIN


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


@export var scene_credits:PackedScene
@export var scene_main:PackedScene


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pos_top_visible=$topUI.global_position
	pos_top_hidden=pos_top_visible+Vector2(0,-32)
	pos_bottom_visible=$bottomUI.global_position
	pos_bottom_hidden=pos_bottom_visible+Vector2(0,24)
	
	GlobalVariables.SetupComplete.connect(SetupComplete)
	
	UpdateHUDPosition(showHud)
	
	$MainMenu/Label.text=version
	pass # Replace with function body.

func SetupComplete():
	
	var hasSaveGame= !GlobalVariables.currentDay==1 #lmao
	StartMainMenu(hasSaveGame)


func StartMainMenu(hasSaveGame:bool):
	
	if hasSaveGame:
		GlobalVariables.MainSceneReferenceConnector.ref_home.MainMenu_SetupSleepIdle()
	SetState(menuStates.MAIN)	
	pass

func GetLightManager():
	return HUD_lightBulbManager

func SetHudVisible(_show:bool):
	
	if showHud!=_show:
		isLerping=true
		lerpCounter=0

	showHud=_show
		
func UpdateHUDPosition(show:bool):
	if show:
		ui_top.global_position=pos_top_visible
		ui_bottom.global_position=pos_bottom_visible
	else:
		ui_top.global_position=pos_top_hidden
		ui_bottom.global_position=pos_bottom_hidden
	pass

func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_tab") and Input.is_action_pressed("escape") and GlobalVariables.DebugEnabled:
		
		if sceneState==sceneStates.MAIN:
			SetSceneState(sceneStates.CREDITS,true)
			
		elif sceneState==sceneStates.CREDITS:
			SetSceneState(sceneStates.MAIN,true)
			

	
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
	
	if state==menuStates.PLAY:
		if Input.is_action_just_pressed("escape") and GlobalVariables.playerStatus != GlobalVariables.playerStatusEnum.SHOP:
			SetState(menuStates.PAUSE)
			
func SetState(_state:menuStates):
	previousMenuState=state
	state=_state
	
	
	match state:
		menuStates.MAIN:
			SetHudVisible(false)
			MainMenu.show()
			MainMenu.SetShouldBeVisible(true)
			MainMenu.GenerateMainMenu()
			GlobalVariables.PlayerController.SetPlayerHidden(true)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.MENU
			
			OptionsMenu.SetMenuActive(false)
			PauseMenu.SetActive(false)


			pass
		menuStates.PAUSE:
			MainMenu.Deactivate()
			OptionsMenu.SetMenuActive(false)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.MENU
			PauseMenu.SetActive(true)

			pass
		menuStates.OPTIONS:
			MainMenu.Deactivate()
			OptionsMenu.SetMenuActive(true)
			PauseMenu.SetActive(false)


			pass
		menuStates.PLAY:
			SetHudVisible(true)			
			GlobalVariables.MainSceneReferenceConnector.ref_camera.SetFollowPlayer(true)
			GlobalVariables.PlayerController.SetPlayerHidden(false)
			GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
			MainMenu.Deactivate()
			OptionsMenu.SetMenuActive(false)
			PauseMenu.SetActive(false)
			
			#If player has saved game, wake up on egg
			if GlobalVariables.currentDay>1 and previousMenuState==menuStates.MAIN:
				GlobalVariables.MainSceneReferenceConnector.ref_home.WakeUp(false)
		menuStates.CREDITS:
			SetHudVisible(false)
			MainMenu.Deactivate()
			OptionsMenu.SetMenuActive(false)
			PauseMenu.SetActive(false)

			
			
func ResetSaveData():
	
	
	pass

func SetSceneState(state:sceneStates,debug:bool=false,resetSaveData:bool=true):
	
	sceneState=state
	if sceneState==sceneStates.MAIN:
		if GlobalVariables.CreditsSceneReferenceConnector:
			
			if resetSaveData:
				GlobalVariables.ResetSaveData() #Resets the players progress!! To be handled with care
			$TransitionToMain.play("FadeBack")
			await get_tree().create_timer(0.05).timeout
			
			var scene = GlobalVariables.CreditsSceneReferenceConnector.ref_credits_parent
			scene.get_tree().change_scene_to_packed(scene_main)
			GlobalVariables.InitialSetup=true
			await GlobalVariables.SetupComplete
			SetState(menuStates.MAIN)
			
	
	if sceneState==sceneStates.CREDITS:
		var scene = GlobalVariables.MainSceneReferenceConnector.mainScene
		scene.get_tree().change_scene_to_packed(scene_credits)
		
	
	pass

func _on_main_menu_new_game() -> void:
	
	if !GlobalVariables.hasSeenIntroCutscene:
		
		#plays the intro cutscene 
		var introCutscene=GlobalVariables.MainSceneReferenceConnector.introCutscene
		
		if !introCutscene.GetIsPlaying():
			MainMenu.SetShouldBeVisible(false)
			await get_tree().create_timer(2).timeout
			introCutscene.Play()
			introCutscene.cutscene_finished.connect(introCutsceneFinished)
	else:
		
		#this is when you press "continue" instead of "new game" 
		SetState(menuStates.PLAY)
		

func introCutsceneFinished():
	SetState(menuStates.PLAY)
	GlobalVariables.hasSeenIntroCutscene=true
	$TransitionToMain.play("FadeBack")

	pass # Replace with function body.


func _on_main_menu_press_options() -> void:
	SetState(menuStates.OPTIONS)
	pass # Replace with function body.


func _on_options_options_closed() -> void:
	
	if previousMenuState==menuStates.MAIN:
		SetState(menuStates.MAIN)
	
	if previousMenuState==menuStates.PAUSE:
		SetState(menuStates.PAUSE)
	
	pass # Replace with function body.


func _on_pause_signal_pause_menu_closed() -> void:
	
	SetState(menuStates.PLAY)
	
	pass # Replace with function body.


func QuitGame():

	get_tree().quit()
	
	pass
