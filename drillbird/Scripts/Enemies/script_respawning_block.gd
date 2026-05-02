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

func _process(delta: float) -> void:
	if blockExists:
		return
	
	if playerCollidersInArea>0:
		respawnCounter=0
	else:
		respawnCounter+=delta
		
	if respawnCounter>timeToRespawn:
		respawnCounter=0
		UpdateAnim("respawn")
		await get_tree().create_timer(0.2).timeout
		RespawnTile()
		
	

func RespawnTile():
	if tileCreator:
		tileCreator.CreateTile(self.global_position,tileCreator.tileTypes.respawning)
		if showDebug: print_debug("block respawned lol")
		blockExists=true
	pass


func _on_player_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	playerCollidersInArea+=1
	pass # Replace with function body.


func _on_player_checker_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	playerCollidersInArea-=1
	pass # Replace with function body.
