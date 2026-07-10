extends Node2D
class_name respawning_block

var tileCreator:object_spawner
var tileDestroyer:crack_script
var tilemap:TileMapLayer
var tileToTarget:Vector2i


@onready var animator:AnimatedSprite2D=$AnimatedSprite2D
@onready var Observer=$Observer

@export var timeToRespawn:float

@onready var debugText=$Label
@export var showDebug:bool=false

var respawnCounter:float=0
var blockExists:bool=true
var blockInfo:TileData

var playerCollidersInArea:int=0

func Setup(_tile_destroyer:crack_script, _tilemap:TileMapLayer,_tile_creator:object_spawner):
	
	tileCreator=_tile_creator
	tilemap=_tilemap
	tileDestroyer=_tile_destroyer
	

	tileToTarget=_tilemap.local_to_map(_tilemap.to_local(self.global_position))
	blockInfo=_tilemap.get_cell_tile_data(tileToTarget)	
	Observer.BlockDestroyed.connect(BlockDestroyed)
	
	RespawnTile()
	pass

func UpdateAnim(anim:String):
	if animator.animation!=anim:
		animator.play(anim)

func BlockDestroyed():
	if tilemap:
		blockExists=false
		
		if showDebug: print_debug("block destroyed")
		UpdateAnim("destroy")
		await get_tree().create_timer(0.2).timeout
		UpdateAnim("idle")
		
	
	pass

var isRespawning:bool=false
func _process(delta: float) -> void:
	if blockExists:
		return
	
	
	
	if playerCollidersInArea>0:
		respawnCounter=0
	else:
		respawnCounter+=delta
		
	if respawnCounter>timeToRespawn:
		if GetIsThereSomeoneOnTile(): #if someone's in the tile, extend the timer
			respawnCounter=0
		else:
			if !isRespawning: #ensure function is enterd once since I use timers in process lol
				isRespawning=true
				respawnCounter=0
				UpdateAnim("respawn")
				await get_tree().create_timer(0.2).timeout
				if !GetIsThereSomeoneOnTile():
					RespawnTile()
					isRespawning=false
				else: 
					UpdateAnim("idle") #handle if player goes into respawn block right b4 it respawns
					respawnCounter=0
					isRespawning=false

		

func GetIsThereSomeoneOnTile()->bool:
	var bodies:Array[Node2D]= $playerChecker.get_overlapping_bodies()
	return bodies.size()>0

func RespawnTile():
	if tileCreator:
		tileCreator.CreateTile(self.global_position,tileCreator.tileTypes.respawning)
		if showDebug: print_debug("block respawned lol")
		blockExists=true
	pass
