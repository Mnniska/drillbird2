extends Node
class_name flying_credits_manager 

@onready var flyer:flying_child=$FlyingChild
@onready var credits=$Credits
@onready var valueSpawner=$ValueSpawner

@onready var backgroundBase:Sprite2D=$BG_base
@onready var backgroundStars:Sprite2D=$BG_Stars
@onready var backgroundPlanets:Sprite2D=$BG_planets
@onready var backgroundClouds:Sprite2D=$BG_clouds
@onready var backgroundCloudsCloser:Sprite2D=$BG_clouds2

@export var BaseSpeed:float=50

@export var debugSkipCredits:bool=false

func _ready() -> void:
	HUD.SetState(HUD.menuStates.CREDITS)
	SetupParallax()
	
	await get_tree().create_timer(1).timeout
	flyer.initiateJump(1)

	if debugSkipCredits:
		valueSpawner.active=true
	else:
		credits.active=true
		credits.signal_credits_finished.connect(CreditsFinished)
		

func CreditsFinished():
	valueSpawner.active=true

func SetupParallax():
	
	var speed=BaseSpeed
	#backgroundBase.material.set_shader_parameter("motion",Vector2i(0,0))
	backgroundStars.material.set_shader_parameter("motion",Vector2i(speed*0.1,0))
	backgroundPlanets.material.set_shader_parameter("motion",Vector2i(speed*0.4,0))
	backgroundClouds.material.set_shader_parameter("motion",Vector2i(speed,0))
	backgroundCloudsCloser.material.set_shader_parameter("motion",Vector2i(speed*1.5,0))
	
	
	pass


func _on_player_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	flyer.initiateJump(randf_range(0.3,0.6))
	pass # Replace with function body.
