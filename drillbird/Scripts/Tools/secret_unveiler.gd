extends Area2D
class_name secret_revealer
#should be loaded in somehow based on save data, can handle later :) 
var unveiled:bool=false
@export var coordinate:Vector2i

@export var useRelativePositioning:bool=false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func UnveilTargetTilemap(simulated:bool=false):
	unveiled=true
	var tilemap:tilemap_secrets_manager=GlobalVariables.MainSceneReferenceConnector.ref_secretTilemap
	
	if useRelativePositioning:
		tilemap.TryUnveilAtRelativePosition(global_position,coordinate,simulated)
	else:
		tilemap.TryUnveilTargetPosition(coordinate,simulated)
	
	
	
	pass

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if !unveiled:
		UnveilTargetTilemap()
	
	
	pass # Replace with function body.
