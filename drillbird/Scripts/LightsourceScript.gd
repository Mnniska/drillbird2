extends Node2D
@export var range=200
@export var collType:abstract_collidable

func _on_area_2d_body_shape_entered() -> void:
	GlobalVariables.amountOfLightsourcesPlayerIsIn+=1
	
	pass # Replace with function body.


func _on_area_2d_body_shape_exited() -> void:
	GlobalVariables.amountOfLightsourcesPlayerIsIn-=1
	pass # Replace with function body.


func _on_audio_stream_player_2d_finished() -> void:
	$AudioStreamPlayer2D.play()
	pass # Replace with function body.
