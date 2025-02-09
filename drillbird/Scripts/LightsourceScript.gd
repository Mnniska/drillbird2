extends Node2D
@export var range=200
@export var collType:abstract_collidable

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	GlobalVariables.amountOfLightsourcesPlayerIsIn+=1
	
	pass # Replace with function body.


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	GlobalVariables.amountOfLightsourcesPlayerIsIn-=1
	pass # Replace with function body.
