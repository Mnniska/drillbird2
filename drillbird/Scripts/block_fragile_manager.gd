extends Node2D
class_name block_fragile_manager
@onready var fragileObserver=preload("res://Scenes/Objects and Enemies/fragile_observer.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func GenerateObservers(tilemap:TileMapLayer,crackscript:crack_script):
	
	#Assumes fragile tiles has the ATLAS source ID == 1
	for tile in tilemap.get_used_cells_by_id(1):
		var globalLoc=to_global( tilemap.map_to_local(tile))
		
		var node = fragileObserver.instantiate()
		add_child(node)
		node.global_position=globalLoc
		node.GenerateObservers(tile,tilemap,crackscript)
		
		#Spawn observer here! 
	pass
