extends Node2D

@export var allTheChunks:Array[abstract_chunk]
@export var caveWidthInchunks:int=4
@export var caveDepthInChunks:int=4

@onready var tilemap:TileMapLayer=$Environment

#hmm.. need to generate some chunkers and have them increase in difficulty over time 
#Ideally the cave should have slightly different layouts per run as well, but can handle that later 

#The level generator spawns in all of the chunks that are wanted live, save them down into an array,
#and then recreates those tiles in the level..although maybe it cannot check those without spawning them?
#ideally it should have access to all of the chunk scripts from the get-go 
#Maybe the chunk scripts could save themselves down as resources, which are then accessed? So one chunk=one resource 

func _ready() -> void:
	LoadAllChunks()
	GenerateChunk()
	pass

func LoadAllChunks():
	
	
	
	for file_name in DirAccess.get_files_at("res://CHUNKS/"):
		if (file_name.get_extension() == "tres"):
			allTheChunks.append(load("res://CHUNKS/"+file_name))
			print(file_name)
	
func GetTileSourceFromTerrain(terrain:int)->int:
	
	match terrain:
		0: return 3 #solid
		1: return 1 #sand
		2: return 2 #dirt
		3: return 4 #dirt2
		4: return 9 #dirt3
		5: return 1 #fragile 
		6: return 12 #demo material lol
	
	return 0
	
func GenerateChunk():
	
	var iterator:int=0
	var positions:Array[Vector2i]
	var terrainCollections:Array[Array]
	
	for n in 10:
		terrainCollections.append(positions)
	
	
	for chunkinfo in allTheChunks:
		for tilepos:Vector2i in chunkinfo.positions:
			var pos=chunkinfo.positions[iterator]
			var terrain=chunkinfo.terrains[iterator]
			
			if terrain!=-1:
				tilemap.set_cell(pos,GetTileSourceFromTerrain(terrain),Vector2i(0,0))
				
			else:
				pass
				#TODO: Ask spawner script to place object/enemy :) 
						

			

			iterator+=1

	#hmm so I can't just ask for a bitmask update making the cells connect..
	#Instead I need to gather all of the cells and tell them to update using the correct terrain..in several calls
	#I don't wanna just a plugin just yet, because it adds more licenses etc
	#so let's try to this..how would I do this nicely.. 

	#todo 2 - make tiles connect correctly
	
	
	
	tilemap.set_cells_terrain_connect(tilemap.get_used_cells(),0,0)
