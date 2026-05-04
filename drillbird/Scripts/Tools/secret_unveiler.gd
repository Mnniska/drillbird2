extends Area2D
class_name secret_revealer
#should be loaded in somehow based on save data, can handle later :) 
var unveiled:bool=false
@export var coordinate:Vector2i

@export var useRelativePositioning:bool=false



func UnveilTargetTilemap(simulated:bool=false):
	unveiled=true
	var tilemap:tilemap_secrets_manager=GlobalVariables.MainSceneReferenceConnector.ref_secretTilemap
	
	if useRelativePositioning:
		tilemap.TryUnveilAtRelativePosition(global_position,coordinate,simulated)
	else:
		tilemap.TryUnveilTargetPosition(coordinate,simulated)
	
	
	
	pass

func _on_body_shape_entered() -> void:
	
	if !unveiled:
		UnveilTargetTilemap()
	
	
	pass # Replace with function body.
