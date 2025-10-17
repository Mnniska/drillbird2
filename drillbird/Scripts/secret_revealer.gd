extends Node2D

@onready var tilemap:TileMapLayer= %Tilemap_secrets

func RevealSecretChunk():
	
	
	#Check if colliding with a tilemap 
	#if so - tell the tiles to destroy themselves via a "reveal" effect of some kind 
	
	tilemap.modulate=Color(Color.WHITE,0)
	
	
	
	pass


func _on_affected_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	RevealSecretChunk()
	
	pass # Replace with function body.
