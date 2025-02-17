extends Node
class_name flying_credits_manager 

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
