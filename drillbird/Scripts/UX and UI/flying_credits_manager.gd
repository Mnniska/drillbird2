extends Node
class_name flying_credits_manager 

@onready var flyer:flying_child=$FlyingChild

@onready var backgroundBase:Sprite2D=$BG_base
@onready var backgroundStars:Sprite2D=$BG_Stars
@onready var backgroundPlanets:Sprite2D=$BG_planets
@onready var backgroundClouds:Sprite2D=$BG_clouds

@export var BaseSpeed:float=50


func _ready() -> void:
	HUD.SetState(HUD.menuStates.CREDITS)
	SetupParallax()


func SetupParallax():
	
	var speed=BaseSpeed
	#backgroundBase.material.set_shader_parameter("motion",Vector2i(0,0))
	backgroundStars.material.set_shader_parameter("motion",Vector2i(speed*0.1,0))
	backgroundPlanets.material.set_shader_parameter("motion",Vector2i(speed*0.4,0))
	backgroundClouds.material.set_shader_parameter("motion",Vector2i(speed,0))
	
	
	pass


func _on_player_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	flyer.initiateJump(randf())
	pass # Replace with function body.
