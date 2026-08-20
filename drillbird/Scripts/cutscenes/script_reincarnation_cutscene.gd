extends Node2D
class_name demon_reincarnation_cutscene
@onready var anim:AnimatedSprite2D=$animation
@onready var cameraLerpDest=$CameraLerpDestination

signal cutscene_finished

var player:Node2D
var camera:game_camera

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var skipUsed:bool=false
func SkipButtonPressed():
	skipUsed=true
	cutscene_finished.emit()
	pass

func PlayCutscene():
	show()
	skipUsed=false
	player=GlobalVariables.PlayerController
	if GlobalVariables.hasSeenDemonDeal:
		HUD.SetSkipButtonEnabled(true)
		GlobalVariables.PlayerPressedSkipButton.connect(SkipButtonPressed)
	
	if player:
		player.hide()
	
	camera=GlobalVariables.MainSceneReferenceConnector.ref_camera
	
	camera.StartNewLerp(cameraLerpDest.global_position,1)
	
	await get_tree().create_timer(1.3).timeout
	if skipUsed:
		return
	anim.play("demon_murder")
		
	anim.animation_finished.connect(AnimationFinished)
	
var cutsceneComplete:bool=false
func AnimationFinished():
	if skipUsed:
		return
	GlobalVariables.hasSeenDemonDeal=true
	HUD.SetSkipButtonEnabled(false)
	cutscene_finished.emit()
	pass
