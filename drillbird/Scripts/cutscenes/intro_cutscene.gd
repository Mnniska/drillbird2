extends Node2D
signal cutscene_finished
@onready var player:AnimationPlayer=$AnimationPlayer
var camera:game_camera
var switchingScene:bool=false

enum cutsceneSounds{ scene1,scene2,scene3 }

var skipTime:float=3
var skipTimeCounter:float=0

@export var cameraPositions:Array[Node2D]
var currentpos:int=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(SetupComplete)
	pass # Replace with function body.
func SetupComplete():
	camera=GlobalVariables.MainSceneReferenceConnector.ref_camera

func _process(delta: float) -> void:
	
	if Input.is_action_pressed("drill") or Input.is_action_pressed("interact"):
		skipTimeCounter+=delta
		if skipTimeCounter>skipTime:
			_on_animation_player_animation_finished("3")
			pass
	else:
		skipTimeCounter = max(0, skipTimeCounter-delta)


func Play():
	_on_animation_player_animation_finished("")

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
		
		GlobalVariables.PlayerController.TriggerDazed()
		#this is a pretty lmao way to trigger the dazed state but I will take it

	
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
