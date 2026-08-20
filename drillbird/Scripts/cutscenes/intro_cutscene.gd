extends Node2D
signal cutscene_finished
@onready var player:AnimationPlayer=$AnimationPlayer
var camera:game_camera
var switchingScene:bool=false
var isPlaying:bool=false

enum cutsceneSounds{ scene1,scene2,scene3 }

@export var cameraPositions:Array[Node2D]
var currentpos:int=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(SetupComplete)
	pass # Replace with function body.
func SetupComplete():
	camera=GlobalVariables.MainSceneReferenceConnector.ref_camera

func GetIsPlaying():
	return isPlaying


func SkipButtonPressed():
	if isPlaying:
		_on_animation_player_animation_finished("3")
		
		#TODO: Have cutscenes remember if they've been played or not
		#TODO: Add an optional dialogue for the demon in normal mode. 
		#Speed up time when holding SING??? lmao 
		#If you haven't finished the game, have them give the player a tip that they can skip cutscenes using "sing"
	pass

func Play():
	isPlaying=true
	_on_animation_player_animation_finished("")
	
	if GlobalVariables.hasSeenIntro:
		HUD.SetSkipButtonEnabled(true)
		GlobalVariables.PlayerPressedSkipButton.connect(SkipButtonPressed)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	
	if anim_name=="":
		PlayScene(1)
	if anim_name=="1":
		PlayScene(2)
	if anim_name=="2":
		PlayScene(3)
	if anim_name=="3":
		cutscene_finished.emit()
		player.play("default")
		camera.SetFollowPlayer(true)
		isPlaying=false
		GlobalVariables.PlayerController.TriggerDazed()
		HUD.SetSkipButtonEnabled(false)
		#this is a pretty lmao way to trigger the dazed state but I will take it
		#seb 9 months later: I agree
		GlobalVariables.hasSeenIntro=true
		GlobalVariables.PlayerPressedSkipButton.disconnect(SkipButtonPressed)


	
func PlayScene(anim:int):
	var thing=str(anim)
	player.play(thing)
	camera.StartNewLerp(cameraPositions[anim-1].global_position,0)

	
func PlaySound(sound:cutsceneSounds):
	
	var soundEffectType:abstract_SoundEffectSetting.SoundEffectEnum
	
	match sound:
		cutsceneSounds.scene1:
			soundEffectType=abstract_SoundEffectSetting.SoundEffectEnum.INTRO_CUTSCENE_SCENE1
			pass
		cutsceneSounds.scene2:
			soundEffectType=abstract_SoundEffectSetting.SoundEffectEnum.INTRO_CUTSCENE_SCENE2
			pass
		cutsceneSounds.scene3:
			soundEffectType=abstract_SoundEffectSetting.SoundEffectEnum.INTRO_CUTSCENE_SCENE3
			pass
				
	SoundManager.PlaySoundGlobal(soundEffectType)
	
	
	pass
