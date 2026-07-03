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


func PlayCutscene():
	show()
	player=GlobalVariables.PlayerController
	
	if player:
		player.hide()
	
	camera=GlobalVariables.MainSceneReferenceConnector.ref_camera
	
	camera.StartNewLerp(cameraLerpDest.global_position,1)
	
	await get_tree().create_timer(1.3).timeout
	
	anim.play("demon_murder")
		
	anim.animation_finished.connect(AnimationFinished)
	

func AnimationFinished():
	
	cutscene_finished.emit()
	pass
