extends Node2D
@export var range=200
@export var collType:abstract_collidable
@export var enabled:bool=true
var playerIsInLight:bool=false

func _on_area_2d_body_shape_entered(_body_rid:RID,_body:Node2D,_body_shape_index:int,_local_shape_index:int) -> void:
	if enabled:
		GlobalVariables.amountOfLightsourcesPlayerIsIn+=1
		playerIsInLight=true
	
	pass # Replace with function body.


func _on_area_2d_body_shape_exited(_body_rid:RID,_body:Node2D,_body_shape_index:int,_local_shape_index:int) -> void:
	if enabled:
		GlobalVariables.amountOfLightsourcesPlayerIsIn-=1
		playerIsInLight=false
	pass # Replace with function body.

func SetEnabled(_enabled:bool):
	enabled=_enabled

	if playerIsInLight and !enabled:
		GlobalVariables.amountOfLightsourcesPlayerIsIn-=1
	
	#TODO: Check if player is in lightsource when enabling it. Should not matter for our purposes tho

func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
	pass # Replace with function body.
