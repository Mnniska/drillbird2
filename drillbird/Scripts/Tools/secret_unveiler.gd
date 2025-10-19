extends Area2D

#should be loaded in somehow based on save data, can handle later :) 
var unveiled:bool=false
@export var positionToUnveil:Vector2i



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func UnveilTargetTilemap(pos:Vector2i):
	unveiled=true
	var tilemap:tilemap_secrets_manager=GlobalVariables.MainSceneReferenceConnector.ref_secretTilemap
	tilemap.TryUnveilTargetPosition(pos)
	
	
	
	pass

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if !unveiled:
		UnveilTargetTilemap(positionToUnveil)
	
	
	pass # Replace with function body.
