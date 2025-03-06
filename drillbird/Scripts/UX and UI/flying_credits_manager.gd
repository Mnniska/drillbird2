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

var cloudsVisible:bool=true
var cloudsVisibleLerper:float=0

func _ready() -> void:
	HUD.SetState(HUD.menuStates.CREDITS)
	
	await get_tree().create_timer(1).timeout
	flyer.initiateJump(1)

	if debugSkipCredits:
		valueSpawner.active=true
		SetCloudsVisible(false)
	else:
		SetCloudsVisible(true)
		credits.active=true
		credits.signal_credits_finished.connect(CreditsFinished)
		

func CreditsFinished():
	valueSpawner.active=true
	SetCloudsVisible(false)

func SetCloudsVisible(visible:bool):
	backgroundClouds.showParallax=visible
	backgroundCloudsCloser.showParallax=visible


func _on_player_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	flyer.initiateJump(randf_range(0.3,0.6))
	pass # Replace with function body.


func _on_flying_child_has_evolved() -> void:
	valueSpawner.active=false
	


func _on_flying_child_has_evolved_off_screen() -> void:
	
	#TODO: Load title screen	
	pass # Replace with function body.
