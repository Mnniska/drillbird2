extends Node2D
signal cutscene_finished
@onready var player:AnimationPlayer=$AnimationPlayer
var camera:game_camera
var switchingScene:bool=false

@export var cameraPositions:Array[Node2D]
var currentpos:int=0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(SetupComplete)
	pass # Replace with function body.
func SetupComplete():
	camera=GlobalVariables.MainSceneReferenceConnector.ref_camera

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_tab"):
		#camera.StartNewLerp(cameraPositions[currentpos].global_position,0)
		#currentpos+=1
		
		Play()

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

	
func PlayScene(anim:int):
	var thing=str(anim)
	player.play(thing)
	camera.StartNewLerp(cameraPositions[anim-1].global_position,0)

	
	pass
