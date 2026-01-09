extends Node

@onready var tilemap:TileMapLayer = $map_environment

@export var chunkdata:abstract_chunk

var allTiles:Array[tileinfo]

func _ready() -> void:
	SaveChunk()
	
	pass

func SaveChunk():
	
	var tile:tileinfo=tileinfo.new()
	for pos in tilemap.get_used_cells():
		
		var tiledata =tilemap.get_cell_tile_data(pos)
		tile.pos=pos		
		tile.terrain=tiledata.terrain
		if tiledata.has_custom_data("enemy_typ"):
			tile.enemyType=tiledata.get_custom_data("enemy_typ")
		if tiledata.has_custom_data("object_type"):
			tile.objectType=tiledata.get_custom_data("object_type")
		allTiles.append(tile)
	
	
	chunkdata.chunk=allTiles
	
	var res:abstract_chunk = chunkdata.duplicate()
	
	res = chunkdata.duplicate()
	
	#need a way to read existing file system so that it generates a unique name when saving?
	var name:String="chunk_depth"+str(res.depth)
	

	var filepath = "res://CHUNKS/"+name+".tres"
	ResourceSaver.save(res,filepath)
	#res.take_over_path(filepath)

#I'd like to preload the tilemaps b4 play so that they're saved to a data structure, available
#to use for the geneerator script

#Should prolly look up chunk based lvl generation

#A tile resource that contains:
# 1. position? 
# 2. Tile type 
