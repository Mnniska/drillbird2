extends Node2D
@export var potentialEnemyStrings:Array[String]
@export var potentialObjectStrings:Array[String]


@onready var gameTilemap:TileMapLayer=$"../TilemapEnvironment" 



var spawnedEnemies:Array[Node2D]

var enemiesToSpawnList:Array[abstract_enemy]

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
	
	
	#EnemyObjectTilemap.hide()
	#TODO: Instead of hiding tilemap, make sure to hide the object representations

	pass

func LoadEnemySpawns(spawnpos:Array[Vector2i],enemytype:Array[int],enemyDead:Array[bool]):
	
	enemiesToSpawnList.clear()
	for n in spawnpos.size():
		var enemy= abstract_enemy.new()
		enemy.spawnLocation=spawnpos[n]
		enemy.type=enemytype[n]
		enemy.dead=enemyDead[n]
		enemiesToSpawnList.append(enemy)
	
	pass

func GenerateObjectsAndEnemiesFromTilemap():
	
	enemiesToSpawnList.clear()
	var tiles:Array[Vector2i] = gameTilemap.get_used_cells()

	var NoSavedEnemies= enemiesToSpawnList.size()<=0

	var index=0
	for tileLoc:Vector2i in tiles:
		var tile:TileData = gameTilemap.get_cell_tile_data(tileLoc)
		
		

		#Is it an enemy? If so, add it to the list of enemies to spawn
		if NoSavedEnemies && !tile.get_custom_data("enemy_type")==0: #zero is default value, meaning this is not an enemy
			var newEnemy=abstract_enemy.new()
			newEnemy.type=tile.get_custom_data("enemy_type")
			newEnemy.spawnLocation=tileLoc
			newEnemy.dead=false
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
		
		
		index+=1
			
	return enemiesToSpawnList
	
	
	pass
	


func GenerateObjectsFromTilemap():
	var ObjectSpawnLocations = gameTilemap.get_used_cells()

	for n in ObjectSpawnLocations.size():
		var tile:TileData = gameTilemap.get_cell_tile_data(ObjectSpawnLocations[n])
		var type=tile.get_custom_data("object_type")
		if !type<=0:
			
			var object = load(potentialObjectStrings[type-1]) 
			var node = object.instantiate()

			var localSpawnPos= gameTilemap.map_to_local(ObjectSpawnLocations[n]) 			
			
			node.transform.origin = localSpawnPos
			add_child(node)
			
			
			pass
	
	pass

func GenerateEnemySpawnsFromTilemap():
	#Should only be done if there is no save data
	#Creates a new abstract_enemy per spawn location and adds it to a list
	enemiesToSpawnList.clear()
	var enemySpawnLocations = gameTilemap.get_used_cells()

	var index=0
	for n in enemySpawnLocations:
		var tile:TileData = gameTilemap.get_cell_tile_data(enemySpawnLocations[index])
		
		if !tile.get_custom_data("enemy_type")==0: #zero is default value, meaning this is not an enemy
			var newEnemy=abstract_enemy.new()
			newEnemy.type=tile.get_custom_data("enemy_type")
			newEnemy.spawnLocation=enemySpawnLocations[index]
			newEnemy.dead=false
			enemiesToSpawnList.append(newEnemy)
		index+=1
			
	return enemiesToSpawnList
	

func SpawnAllEnemies():

	#Spawns all enemies in the EnemiesToSpawn list. This list is loaded from savefile or setup during first play

	var index=0
	for n in enemiesToSpawnList:
		
		var enemy = load(potentialEnemyStrings[enemiesToSpawnList[index].type-1]) #The -1 is due to 0 acting as there being NO enemy
		var node = enemy.instantiate()
		spawnedEnemies.append(node)	

		#We convert it to map coords so that enemy is spawned in the middle of the tile
		var SpawnPositionInMapCoordinates= gameTilemap.local_to_map(gameTilemap.to_local(enemiesToSpawnList[index].spawnLocation))
		var spawnPointInLocalCoords= gameTilemap.map_to_local(SpawnPositionInMapCoordinates) 
		
		var spawnPosLocalCoords=gameTilemap.map_to_local(enemiesToSpawnList[index].spawnLocation)
		
		node.Setup(n)
		node.transform.origin = spawnPosLocalCoords
		add_child(node)
		index+=1
			
	pass


func GetEnemyUpdate():
	
	var index=0
	for n in spawnedEnemies:
		
		enemiesToSpawnList[index].dead=n.enemyInfo.dead

		#Converts enemy spawn position into closest tilemap coordinate
		var spawnpos:Vector2i=gameTilemap.local_to_map(gameTilemap.to_local(n.GetLocalSpawnPosition()))
		#Converts CURRENT position into tilemap coordinates
		var newpos:Vector2i=gameTilemap.local_to_map(gameTilemap.to_local(n.position))

		if spawnpos!=newpos:
			#MoveTileToNewPos(spawnpos,newpos)
			enemiesToSpawnList[index].spawnLocation=newpos
		
		pass
		index+=1
	return enemiesToSpawnList
	pass

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
			
		
