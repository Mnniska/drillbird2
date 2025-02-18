extends Node2D
@onready var camera:Camera2D=%Camera2D

@onready var bg_space:Sprite2D=$BG_space
@onready var bg_stars:Sprite2D=$BG_stars
@onready var bg_planet:Sprite2D=$BackgroundPlanets
@onready var bg_clouds2:Sprite2D=$BG_clouds2
@onready var bg_clouds1:Sprite2D=$BG_clouds1

@onready var parallaxtest:single_parallax=$BackgroundPlanets

var player
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(GetPlayer)
	pass # Replace with function body.

func GetPlayer():
	player=GlobalVariables.MainSceneReferenceConnector.player
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position=camera.get_screen_center_position()

	if player!=null:
		parallaxtest.UpdateParallax(player.global_position)
	
	pass
