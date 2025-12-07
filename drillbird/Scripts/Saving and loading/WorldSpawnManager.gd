extends Node
class_name world_spawn_manager

@export var WorldPaths:Array[String]
var spawnedWorld:Node

var tilemap_environment:TileMapLayer
var tilemap_ores:TileMapLayer
var tilemap_background:TileMapLayer

func SpawnWorld(world:int):
	
	if WorldPaths.size()<world+1:
		print_debug("Attempted to load a world that does not exist. Returning without spawning")
		return
	
	var worldToSpawn = load(WorldPaths[world]) #
	var node = worldToSpawn.instantiate()
	$"..".add_child(node)
	spawnedWorld=node
	

func DespawnWorld():
	
	if spawnedWorld==null:
		print_debug("Attempted to destroy a world that did not exist in WorldSpawner")
		return

	spawnedWorld.queue_free()
