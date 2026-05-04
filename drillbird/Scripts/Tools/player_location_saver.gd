extends Area2D

@export var Spawnpos:Node2D

func _on_body_shape_entered() -> void:
	
	if GlobalVariables.playerSpawnPos!=Spawnpos.global_position:
		GlobalVariables.playerSpawnPos=Spawnpos.global_position
	
	pass # Replace with function body.
