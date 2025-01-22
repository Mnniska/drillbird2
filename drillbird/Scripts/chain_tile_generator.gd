extends Node2D
@onready var tilemap:TileMapLayer=$"../../TilemapEnvironment"

@onready var chaintileRef=preload("res://Scenes/Objects and Enemies/Enemy_Spikes.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func GenerateChaintileObservers():
	
	for n in tilemap.get_used_cells():
		var tiledata:TileData=tilemap.get_cell_tile_data(n)
		if tiledata.terrain_set==1:
			var node:Node2D = chaintileRef.instantiate()
			node.transform.origin=to_local(tilemap.map_to_local(n))
			add_child(node)
			pass
		
		pass
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
