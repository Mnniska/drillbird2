extends Node
class_name world_spawn_manager

@export var WorldPaths:Array[String]
@export var CurrentWorld:int=2


var spawnedWorld:Node

var tilemap_environment:TileMapLayer
var tilemap_ores:TileMapLayer
var tilemap_background:TileMapLayer



func CycleWorld():

#only while devving, should prolly move this in future :) 
	CurrentWorld+=1
	if CurrentWorld>WorldPaths.size()-1:
		CurrentWorld=0
	
	GlobalVariables.currentWorld=CurrentWorld
	print_debug("Set world to spawn to world "+str(CurrentWorld))
	

func SpawnWorld(world:int=0):
	
	CurrentWorld=world
	
	if WorldPaths.size()<world+1:
		print_debug("Attempted to load a world that does not exist. Returning without spawning")
		return
	
	var worldToSpawn = load(WorldPaths[world]) #
	var node = worldToSpawn.instantiate()
	$"..".add_child(node)
	$"..".move_child(node,self.get_index()+1)
	
	spawnedWorld=node
	

func DespawnWorld():
	
	if spawnedWorld==null:
		print_debug("Attempted to destroy a world that did not exist in WorldSpawner")
		return

	spawnedWorld.queue_free()
