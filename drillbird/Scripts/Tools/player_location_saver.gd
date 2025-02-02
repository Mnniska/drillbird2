extends Area2D

@export var Spawnpos:Node2D

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if GlobalVariables.playerSpawnPos!=Spawnpos.global_position:
		GlobalVariables.playerSpawnPos=Spawnpos.global_position
	
	pass # Replace with function body.
