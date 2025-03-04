extends Node2D
signal CutsceneComplete

@onready var anim:AnimationPlayer=$AnimationPlayer
@onready var birdySpriteframes:AnimatedSprite2D=$birdy
@onready var skyCameraPos:Vector2=$cameraLerpPos_sky.global_position
@onready var nestCameraPos:Vector2=$cameraLerpPos_nest.global_position

var birdVibrate:bool=false
@onready var originalPos=$birdy.position

func _ready() -> void:
	hide()

func _process(delta: float) -> void:

		
	if birdVibrate:
		var vibrate=1
		birdySpriteframes.position = originalPos + Vector2(randf_range(-vibrate,vibrate),0)

func VibrateBird():
	birdVibrate=true

func CameraPanToSky():
	GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(skyCameraPos,2)
	await get_tree().create_timer(4).timeout
	GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(nestCameraPos,2)
	
	#make egg transition to natural rest pos here and save game

	pass

func CameraPanBack():
	pass

func Play():
	birdVibrate=false
	GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(nestCameraPos,1)
	await get_tree().create_timer(1.2).timeout

	show()
	anim.play("play")
	birdySpriteframes.play()

	#anim.animation_finished.connect(AnimFinished)
	
func AnimFinished():
	hide()
	CutsceneComplete.emit()
	pass
