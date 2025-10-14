extends Node2D
class_name object_spawner
@export var potentialEnemyStrings:Array[String]
@export var potentialObjectStrings:Array[String]
@onready var flowerReference=preload("res://Scenes/Objects and Enemies/climb_flower.tscn")

@onready var gameTilemap:TileMapLayer=$"../TilemapEnvironment" 

@onready var oreTilemap:TileMapLayer=$"../TilemapOres"

@onready var OreAreas=$"../TilemapOres/OreRegions"
@onready var tileDestroyer=$"../TileCrack"
@onready var fragileBlockManager:block_fragile_manager=$Block_FragileManager


var spawnedEnemies:Array[Node2D]

var enemiesToSpawnList:Array[abstract_enemy]
var loadedEnemiesList:Array[abstract_enemy]

func _process(delta: float) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(GameStart)
	pass # Replace with function body.

#called from savemanager
func GameStart():
	
	GenerateObjectsAndEnemiesFromTilemap()
	SpawnAllEnemies()


	pass

func LoadEnemySpawns(spawnpos:Array[Vector2i],enemytype:Array[int],enemyDead:Array[bool],currentSpawnPos:Array[Vector2i]):
	
	loadedEnemiesList.clear()
	for n in spawnpos.size():
		var enemy= abstract_enemy.new()
		enemy.spawnLocation=spawnpos[n]
		
		if currentSpawnPos.size()>n:
			enemy.currentSpawnLocation=currentSpawnPos[n]
		else:
			enemy.currentSpawnLocation=spawnpos[n]
			
		enemy.type=enemytype[n]
		enemy.dead=enemyDead[n]
		loadedEnemiesList.append(enemy)
	
	pass

func LoadFlowers(flowerSpawnPositions: Array[Vector2i]):
	#spawns flowers at the given positions
	
	for pos in flowerSpawnPositions:
		
		var spawnpos = to_global(gameTilemap.map_to_local(pos))
		CreateNewFlowerFromGlobalPos(spawnpos,true,false)
			

func GenerateObjectsAndEnemiesFromTilemap():
	
	#commented out in enemy load refactor March 2025
	#enemiesToSpawnList.clear() # confused - how can we save enemy data if we destroy the list? Seems incorrect. 
	
	
	var tiles:Array[Vector2i] = gameTilemap.get_used_cells()

	var NoSavedEnemies= enemiesToSpawnList.size()<=0
	
	var tilesToUpdateTerrainOn:Array[abstract_tile_info]

	
	var tileListTest:Array[Vector2i]
	var index=0
	for tileLoc:Vector2i in tiles:
		var tile:TileData = gameTilemap.get_cell_tile_data(tileLoc)
		
		

		#Is it an enemy? If so, add it to the list of enemies to spawn
		#Enemies are spawned in the SpawnAllEnemies function
		if tile.get_custom_data("enemy_type")!=0: #if it's not zero, then it's an enemy!
			var newEnemy=abstract_enemy.new()
			newEnemy.type=tile.get_custom_data("enemy_type")-1 #We put -1 here since the value for NO enemy in the EnvironmentTilemap is zero, but the enemy spawn list starts at zero
			newEnemy.spawnLocation=tileLoc
			var foundmatch:bool=false
			
			for enemy in loadedEnemiesList: #is there a better way do this this then to loop through ALL of the enmies for each enemy spawned? lol
				if enemy.spawnLocation==newEnemy.spawnLocation: 
					#Check whether there is a saved enemy with the same spawn pos as the tilemap
					#if so - spawns the enemy with the saved data
					foundmatch=true
					newEnemy.dead=enemy.dead
					newEnemy.currentSpawnLocation=enemy.currentSpawnLocation
			
			if !foundmatch: #If no save data found, spawn with default values
				newEnemy.dead=false
				newEnemy.currentSpawnLocation=newEnemy.spawnLocation
			
			enemiesToSpawnList.append(newEnemy)
			RemoveTile(tileLoc)
		
		#Is there an object that should be spawned via the tilemap?
		var type=tile.get_custom_data("object_type")
		if !type<=0:
			
			var object = load(potentialObjectStrings[type-1]) 
			var node = object.instantiate()

			var localSpawnPos= gameTilemap.map_to_local(tileLoc) 			
			
			node.transform.origin = localSpawnPos
			add_child(node)
			RemoveTile(tileLoc)
		
			if type==2:
				var flower:climb_flower = node
				flower.SetHasBlossomed(true)
		
	#Does the tile have an ore? If so, place it in the OreTilemap!
		if tile.get_custom_data("oreblock_terrain")>0: #is ore if greater than zero
			
			#Here, we wanna create an ORE SPRITE that matches the current ore region
			var oreRegion:int=GetRelevantOreRegion(tileLoc)
			oreTilemap.set_cell(tileLoc,0,Vector2i(oreRegion,randi_range(0,2)),0) #Sets cell to be one of the ores. The random is to select between the variants
			#todo paint tile with relevant ore
			
			#Set cell to use correct sprite
			var terrainSourceIDs:Array[int]=[3,5,2,4,9] #This is the source ID derived from the oreder of tile atlases in the tilemap settings

			var tileTerrain=tile.get_custom_data("oreblock_terrain")
			var sourceID=terrainSourceIDs[tileTerrain]
			
			
			gameTilemap.set_cell(tileLoc,sourceID,Vector2i(0,0),0)
			
			
			#TilesToUpdate.append(tileLoc)
			var cells:Array[Vector2i]
			
			var newtile=abstract_tile_info.new()
			newtile.loc=tileLoc
			newtile.terrainIdentifier=tileTerrain
			
		

			
			tilesToUpdateTerrainOn.append(newtile)

			pass
		index+=1

	#All of this is done to ensure the tiles connect beautifully 
	var terrains:Array[abstract_tileCollection]

	for n in tilesToUpdateTerrainOn:
		
		#Check if terrain is new - if so, create a new entry in "terrains" and add the tile there
		var terrainExists:bool=false
		for tilesetCollection in terrains:
			if tilesetCollection.terrain==n.terrainIdentifier:
				terrainExists=true
				tilesetCollection.tiles.append(n)
		
		if !terrainExists:
			var terr:abstract_tileCollection=abstract_tileCollection.new()
			terr.terrain=n.terrainIdentifier	
			terr.tiles.append(n)
			terrains.append(terr)
		pass
	
	#After getting all of the tiles of the same terrain type sorted in the same list, we go thru each array and make them connect properly
	for n in terrains:
		var locationArray:Array[Vector2i]
		for p in n.tiles:
			locationArray.append(p.loc)
		gameTilemap.set_cells_terrain_connect(locationArray, 0, n.terrain,false)
	
	fragileBlockManager.GenerateObservers(gameTilemap,tileDestroyer)
	
	return enemiesToSpawnList
	
	
	pass


	
func GetRelevantOreRegion(tilePos:Vector2i):
	
	return OreAreas.GetRegionIdentifierFromLocation(tilePos,gameTilemap)	
	
	pass

	

func SpawnAllEnemies():

	#Spawns all enemies in the EnemiesToSpawn list. This list is loaded from savefile or setup during first play

	var index=0
	for enemyInfo in enemiesToSpawnList:
		
		var enemy = load(potentialEnemyStrings[enemyInfo.type]) #
		var node = enemy.instantiate()
		spawnedEnemies.append(node)	

		var spawnPosLocalCoords=gameTilemap.map_to_local(enemyInfo.currentSpawnLocation)
		

		if node.enemyInfo.type==abstract_enemy.enemyTypes.FALLBLOCK:
			node.BlockDestroyer=tileDestroyer
		
		if enemyInfo.dead==true:
			print_debug("I found a dead enemy!")
		
		node.Setup(enemyInfo)
		node.transform.origin = spawnPosLocalCoords
		add_child(node)
		index+=1
			
	pass

func GetFlowerUpdate()->Array[Vector2i]:
	var p:Array[Vector2i]

	
	for flower:climb_flower in get_tree().get_nodes_in_group("flower"):
		
		if !flower.HasBeenSpawnedViaTilemap and flower.state!=flower.States.GROWING:
			var pos:Vector2i=gameTilemap.local_to_map(gameTilemap.to_local(flower.global_position))
			p.append(pos)
		

	
	return p 

func GetEnemyUpdate():
	
	var index=0
	for n in spawnedEnemies:
		
		enemiesToSpawnList[index].dead=n.enemyInfo.dead
		var currentPos:Vector2i=gameTilemap.local_to_map(gameTilemap.to_local(n.position)) #get enemy pos and convert it to map coords
		enemiesToSpawnList[index].currentSpawnLocation=currentPos
		index+=1
	return enemiesToSpawnList
	pass

func CreateNewFlowerFromGlobalPos(globalPos:Vector2,blossomed:bool=false,playSound:bool=true):
	
	var node:climb_flower=flowerReference.instantiate()
	var mapPos = gameTilemap.local_to_map(to_local(globalPos))
	var gPos=to_local(gameTilemap.map_to_local(mapPos))
	node.transform.origin=gPos
	
	add_child(node)
	node.HasBeenSpawnedViaTilemap=false
	node.SetHasBlossomed(blossomed,playSound)
	
	return node
	

func RemoveTile(pos:Vector2i):
	gameTilemap.set_cell(pos,-1,Vector2i(-1,-1),0)
	


func MoveTileToNewPos(oldpos:Vector2,newpos:Vector2):
	var tile_map_layer = 0 
	var tile_map_cell_position = oldpos 
	var tile_data = gameTilemap.get_cell_tile_data(tile_map_cell_position)
	if tile_data: 
		var tile_map_cell_source_id = gameTilemap.get_cell_source_id(tile_map_cell_position); 
		var tile_map_cell_atlas_coords = gameTilemap.get_cell_atlas_coords(tile_map_cell_position) 
		var tile_map_cell_alternative = gameTilemap.get_cell_alternative_tile(tile_map_cell_position) 
		var new_tile_map_cell_position = newpos
		gameTilemap.set_cell(new_tile_map_cell_position, tile_map_cell_source_id, tile_map_cell_atlas_coords, tile_map_cell_alternative)
			
		
