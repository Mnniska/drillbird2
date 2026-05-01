extends Node2D
class_name object_spawner
@export var potentialEnemyStrings:Array[String]
@export var potentialObjectStrings:Array[String]
@onready var flowerReference=preload("res://Scenes/Objects and Enemies/climb_flower.tscn")

var gameTilemap:TileMapLayer 
var oreTilemap:TileMapLayer
var OreAreas
@onready var tileDestroyer=$"../TileCrack"
@onready var fragileBlockManager:block_fragile_manager=$Block_FragileManager
@onready var corpseHolder=$"corpseholder"
@onready var tombstoneReference=preload("res://Scenes/Objects and Enemies/Enemy_Tombstone.tscn")

var spawnedEnemies:Array[Node2D]

var enemiesToSpawnList:Array[abstract_enemy]
var loadedEnemiesList:Array[abstract_enemy]

func _process(delta: float) -> void:
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.WorldHasBeenSpawned_secondTick.connect(WorldGenerated)
	GlobalVariables.SetupComplete.connect(GameStart)
	pass # Replace with function body.

#called from savemanager
func GameStart():
	

	GenerateObjectsAndEnemiesFromTilemap()
	SpawnAllEnemies()


func WorldGenerated():
	gameTilemap=$"../WorldSpawn/TilemapEnvironment" 
	oreTilemap=$"../WorldSpawn/TilemapOres"
	OreAreas=$"../WorldSpawn/TilemapOres/OreRegions"
	pass

#Called from save game script in top node in Main when starting game
#Spawns all of the enemies based on given data from save system
func LoadEnemySpawns(spawnpos:Array[Vector2i],enemytype:Array[int],enemyDead:Array[bool],currentSpawnPos:Array[Vector2i],spawnedFromCorpse:Array[bool]):
	
	loadedEnemiesList.clear()
	for n in spawnpos.size():
		var enemy= abstract_enemy.new()
		enemy.spawnLocation=spawnpos[n]
		
		if currentSpawnPos.size()>n: #if there's value in currentspawnpos it means it should be updated?
			enemy.currentSpawnLocation=currentSpawnPos[n]
		else:
			enemy.currentSpawnLocation=spawnpos[n]
			
		enemy.type=enemytype[n]
		
		enemy.dead=enemyDead[n]
		enemy.spawnedFromCorpse=spawnedFromCorpse[n]
		
		if enemy.spawnedFromCorpse:
			print_debug("yo spawned from corpse lol")

		
		loadedEnemiesList.append(enemy)
	
	pass

func LoadFlowers(flowerSpawnPositions: Array[Vector2i]):
	#spawns flowers at the given positions
	
	for pos in flowerSpawnPositions:
		
		var spawnpos = to_global(gameTilemap.map_to_local(pos))
		CreateNewFlowerFromGlobalPos(spawnpos,true,false)

enum tileTypes{dirt2,dirt1,sand,dirt3,solid}

func CreateTile(globalPos:Vector2i,_terrain:tileTypes):
	var localPos=gameTilemap.local_to_map(gameTilemap.to_local(globalPos))
	
	var positions:Array[Vector2i]
	positions.append(localPos)
	var terrainTranslated=GetSourceIDFromTerrain(_terrain)

	gameTilemap.set_cells_terrain_connect(positions, 0, terrainTranslated,false)

	
	pass

func GetSourceIDFromTerrain(terrainInt:int)->int:
	
	if terrainInt==10: #Solid blocks have this weird terrain ID because their actual position is 0, which is the default value making things break
		terrainInt=0

	#This is the source ID derived from the oreder of tile atlases in the tilemap settings
	#The order in the TilemapEnvironments tilemap versus the order in the sprites is different, that's why we need to do this translation here

	
	var terrainSourceIDs:Array[int]=[3,2,5,4,9] 
	return terrainSourceIDs[terrainInt]

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
		
		
	#This script relies on each enemy having a reference in the tilemap - it checks the tilemaps enemy reference to see if it has
	#A matching location with any existing enemies. if so - it does not spawn the tilemap enemy, instead spawning it wherever it has moved
	#If a new enemy has been added to the tilemap after saving - it'll be a new entry so no match will be found - the enemy will be added using the default positions
	#However - loaded enemies which does not have a tile simply won't be included I reckon

		#Is it an enemy? If so, add it to the list of enemies to spawn
		#Enemies are spawned in the SpawnAllEnemies function
		if tile.get_custom_data("enemy_type")!=0: #if it's not zero, then it's an enemy!
			var newEnemy=abstract_enemy.new()
			newEnemy.type=tile.get_custom_data("enemy_type")-1 #We put -1 here since the value for NO enemy in the EnvironmentTilemap is zero, but the enemy spawn list starts at zero
			newEnemy.spawnLocation=tileLoc
			var foundmatch:bool=false
			
			#Tries to find a match 
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
			
			var valueToReplaceWithTile=-1
			if newEnemy.type==7:
				valueToReplaceWithTile=tile.get_custom_data("oreblock_terrain")
				
			RemoveTile(tileLoc,valueToReplaceWithTile)
		


		
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
	#This is only used when using the tilemap_editorores tilesheet - used for faster LD flow :) 
	
		if tile.get_custom_data("oreblock_terrain")>0 and tile.get_custom_data("enemy_type")==0: #is ore if greater then -1
				
			#Here, we wanna create an ORE SPRITE that matches the current ore region
			var oreRegion:int=GetRelevantOreRegion(tileLoc)
			oreTilemap.set_cell(tileLoc,0,Vector2i(oreRegion,randi_range(0,2)),0) #Sets cell to be one of the ores. The random is to select between the variants
			
			
			

		
			var tileTerrain=tile.get_custom_data("oreblock_terrain")
			
			#This changes solid blocks from having terrain identifier 10 to the correct identifier
			#The reason it does not have the correct identifier from the start, is that solid tiles have "0" as their terrain identifier - and unfortinutely 
			#that means all solid tiles and empty tiles gain oreblocks. So this is a hack to circumvent that 
			
			var sourceID=GetSourceIDFromTerrain(tileTerrain)
			
			
			gameTilemap.set_cell(tileLoc,sourceID,Vector2i(0,0),0)
			
			
			var newtile=abstract_tile_info.new()
			newtile.loc=tileLoc
			newtile.terrainIdentifier=tileTerrain
			
		

			
			tilesToUpdateTerrainOn.append(newtile)

			pass
		index+=1





	#All of this is done to ensure the tiles connect beautifully 
	var terrains:Array[abstract_tileCollection]

	for indvidualtile in tilesToUpdateTerrainOn:

			
		#Check if terrain is new - if so, create a new entry in "terrains" and add the tile there
		var terrainExists:bool=false
		for tilesetCollection in terrains:
			if tilesetCollection.terrain==indvidualtile.terrainIdentifier:
				#The terrain collection isn't used again, I think??
				terrainExists=true
				tilesetCollection.tiles.append(indvidualtile)
		
		if !terrainExists:
			var terr:abstract_tileCollection=abstract_tileCollection.new()
			terr.terrain=indvidualtile.terrainIdentifier	
			terr.tiles.append(indvidualtile)
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


	
func GetRelevantOreRegion(tilePos:Vector2i):
	
	var region=OreAreas.GetRegionIdentifierFromLocation(tilePos,gameTilemap)
	
	return region


	

func SpawnAllEnemies():

	#Spawns all enemies in the EnemiesToSpawn list. This list is loaded from savefile or setup during first play

	#Some items can be spawned without a tilemap reference and saved, then put into loadedenemieslist
	#For these we use this for loop, adding the enemies to the list b4 going thru it
	for enemy in loadedEnemiesList:
		if enemy.spawnedFromCorpse:
			print_debug("tombstone spawning..")
			enemiesToSpawnList.append(enemy)

	for enemyInfo in enemiesToSpawnList:
		
		if enemyInfo.type==enemyInfo.enemyTypes.TOMBSTONE:
			print_debug("spawning new tombstone..")
		
		if enemyInfo.dead: #simply don't spawn the enemy
			spawnedEnemies.append(null)	#add a null value so that the order is still correct hehe
		else:
			var enemy = load(potentialEnemyStrings[enemyInfo.type]) #
			var node = enemy.instantiate()
			spawnedEnemies.append(node)	

			var spawnPosLocalCoords=gameTilemap.map_to_local(enemyInfo.currentSpawnLocation)
			

			if node.enemyInfo.type==abstract_enemy.enemyTypes.FALLBLOCK or node.enemyInfo.type==abstract_enemy.enemyTypes.SWORDFISH:
				node.BlockDestroyer=tileDestroyer
			
			node.Setup(enemyInfo)
			node.transform.origin = spawnPosLocalCoords
			add_child(node)
			
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
	
	#Called when saving. 
	#Goes through the spawnedEnemies list created during play and updates each entry, adding new position + whether the enemy is dead
	for n in spawnedEnemies:
		
		if n==null: #test to just delete enemies when they die lol, to save some memory
			enemiesToSpawnList[index].dead=true
		else:
	#		enemiesToSpawnList[index].dead=n.enemyInfo.dead
			var currentPos:Vector2i=gameTilemap.local_to_map(gameTilemap.to_local(n.position)) #get enemy pos and convert it to map coords
				
		
			enemiesToSpawnList[index].currentSpawnLocation=currentPos
		index+=1
		
	return enemiesToSpawnList

func CreateNewFlowerFromGlobalPos(globalPos:Vector2,blossomed:bool=false,playSound:bool=true):
	
	var node:climb_flower=flowerReference.instantiate()
	var mapPos = gameTilemap.local_to_map(to_local(globalPos))
	var gPos=to_local(gameTilemap.map_to_local(mapPos))
	node.transform.origin=gPos
	
	add_child(node)
	node.HasBeenSpawnedViaTilemap=false
	node.SetHasBlossomed(blossomed,playSound)
	
	return node

#Should be called when a day passes, which is also done when saving
func TurnCorpsesIntoTombstones():
	
	for corpse:Node2D in corpseHolder.get_children():
		
		#translate the corpse position to center of tile so tombstone spawns in center
		var posInLocalTilemap = gameTilemap.to_local(corpse.global_position)
		var posInTilemapCoords=gameTilemap.local_to_map(posInLocalTilemap)
		var spawnpos=gameTilemap.map_to_local(posInTilemapCoords)
		
		var tombstoneInstance:tombstone=tombstoneReference.instantiate()
		tombstoneInstance.transform.origin=spawnpos
		add_child(tombstoneInstance)
		
		var tombstoneInfo:abstract_enemy=abstract_enemy.new()
		tombstoneInfo.damage=1
		tombstoneInfo.dead=false
		tombstoneInfo.spawnLocation=posInTilemapCoords
		tombstoneInfo.type=tombstoneInfo.enemyTypes.TOMBSTONE
		tombstoneInfo.spawnedFromCorpse=true


		#this tile is the one UNDERNEATH the tombstone, so it does not make sense to check for spikes here
		#also, spikes are enemies, so it does not make sense to check the tilemap for them lol
		
		
		#
		##check if tombstone should spawn with spikes
		#var tileItSpawnsOnto:TileData=gameTilemap.get_cell_tile_data(posInTilemapCoords)
		#var tombstoneHasSpikes:bool=false
		#if tileItSpawnsOnto.get_custom_data("enemy_type")==2:
			#tombstoneHasSpikes=true


		tombstoneInstance.Setup(tombstoneInfo,false)

		#TODO: Saving needs to handle whether tombstones have spikes or not lol

		spawnedEnemies.append(tombstoneInstance)
		enemiesToSpawnList.append(tombstoneInstance.enemyInfo)
		corpse.queue_free()

		#then handle all the exceptions that creates lol
		
		#Can I add to the spawnedenemies list after the fact? I THINK this should be fine lol, let's check the flow after implementing
		#In theory when saving it should create new entries in the enemylist when saving if there's new ones
	

func AddCorpse(corpseInstance):
	corpseHolder.add_child(corpseInstance)
	
	#can't add tombstone here cuz corpse might move, but it's nice we have them gathered under one parent :) 

func RemoveTile(pos:Vector2i,replaceEmptySpaceWithThisTerrain:int=-1):
	
	if replaceEmptySpaceWithThisTerrain==-1:
		gameTilemap.set_cell(pos,-1,Vector2i(-1,-1),0)
	else:
		#Oh god do I need to connect the cells? 
		gameTilemap.set_cell(pos,GetSourceIDFromTerrain(replaceEmptySpaceWithThisTerrain),Vector2i(0,0),0)

func MoveTileToNewPos(oldpos:Vector2,newpos:Vector2):
	var tile_map_cell_position = oldpos 
	var tile_data = gameTilemap.get_cell_tile_data(tile_map_cell_position)
	if tile_data: 
		var tile_map_cell_source_id = gameTilemap.get_cell_source_id(tile_map_cell_position); 
		var tile_map_cell_atlas_coords = gameTilemap.get_cell_atlas_coords(tile_map_cell_position) 
		var tile_map_cell_alternative = gameTilemap.get_cell_alternative_tile(tile_map_cell_position) 
		var new_tile_map_cell_position = newpos
		gameTilemap.set_cell(new_tile_map_cell_position, tile_map_cell_source_id, tile_map_cell_atlas_coords, tile_map_cell_alternative)
			
		
