extends Node2D
class_name respawning_block

var tileCreator:object_spawner
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

func Setup(_tile_destroyer:crack_script, _tilemap:TileMapLayer,_tile_creator:object_spawner):
	
	tileCreator=_tile_creator
	tilemap=_tilemap
	tileDestroyer=_tile_destroyer
	

	tileToTarget=_tilemap.local_to_map(_tilemap.to_local(self.global_position))
	blockInfo=_tilemap.get_cell_tile_data(tileToTarget)	
	Observer.BlockDestroyed.connect(BlockDestroyed)
	
	RespawnTile()
	pass



func BlockDestroyed():
	if tilemap:
		blockExists=false
		
		if showDebug: print_debug("block destroyed")
		
		
	
	pass

func _process(delta: float) -> void:
	if blockExists:
		return
	
	respawnCounter+=delta
	if respawnCounter>timeToRespawn:
		respawnCounter=0
		
		RespawnTile()

	

func RespawnTile():
	if tileCreator:
		tileCreator.CreateTile(self.global_position,tileCreator.tileTypes.respawning)
		if showDebug: print_debug("block respawned lol")
		blockExists=true
	pass
