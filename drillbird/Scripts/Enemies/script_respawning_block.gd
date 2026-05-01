extends Node2D
class_name respawning_block

var tileDestroyer:crack_script
var tilemap:TileMapLayer
var tileToTarget:Vector2i



@onready var Observer=$Observer

@export var timeToRespawn:float

@onready var debugText=$Label
@export var showDebug:bool=false

var respawnCounter:float=0
var blockExists:bool=true
var blockInfo:TileData

func Setup(_tile_destroyer:crack_script, _tilemap:TileMapLayer):
	
	tilemap=_tilemap
	tileDestroyer=_tile_destroyer
	

	tileToTarget=_tilemap.local_to_map(_tilemap.to_local(self.global_position))
	blockInfo=_tilemap.get_cell_tile_data(tileToTarget)	
	Observer.BlockDestroyed.connect(BlockDestroyed)
	
	pass

func BlockDestroyed():
	if tilemap:
		tileDestroyer.DestroyTile(tileToTarget,true,false)
		blockExists=false
		
		if showDebug: print_debug("block destroyed")
		
		
	
	pass

func _process(delta: float) -> void:
	if blockExists:
		return
	
	respawnCounter+=delta
	if respawnCounter>timeToRespawn:
		respawnCounter=0
		blockExists=true
		
		tilemap.set_cell(tileToTarget,0,blockInfo.texture_origin)
		if showDebug: print_debug("block respawned lol")
	
