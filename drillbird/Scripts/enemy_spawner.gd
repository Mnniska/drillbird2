extends Node2D
@export var potentialEnemyStrings:Array[String]
@export var potentialObjectStrings:Array[String]


@onready var EnemyObjectTilemap:TileMapLayer=$"../Tilemap_EnemiesAndObjects"



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
	
	if enemiesToSpawnList.size()<=0:
		#If the save manager hasn't given the spawner any new data, generate enemy positions based on the tilemap
		#The issue with this approach is that the save data completely overwrites the tilemap - so one has to reset
		#save data in order to place new enemies
		GenerateEnemySpawnsFromTilemap()


	SpawnAllEnemies()
	
	GenerateObjectsFromTilemap()
	
	EnemyObjectTilemap.hide()

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
	
func GenerateObjectsFromTilemap():
	var ObjectSpawnLocations = EnemyObjectTilemap.get_used_cells()

	for n in ObjectSpawnLocations.size():
		var tile:TileData = EnemyObjectTilemap.get_cell_tile_data(ObjectSpawnLocations[n])
		var type=tile.get_custom_data("object_type")
		if !type<=0:
			
			var object = load(potentialObjectStrings[type-1]) 
			var node = object.instantiate()

			var localSpawnPos= EnemyObjectTilemap.map_to_local(ObjectSpawnLocations[n]) 			
			
			node.transform.origin = localSpawnPos
			add_child(node)
			
			
			pass
	
	pass

func GenerateEnemySpawnsFromTilemap():
	#Should only be done if there is no save data
	#Creates a new abstract_enemy per spawn location and adds it to a list
	enemiesToSpawnList.clear()
	var enemySpawnLocations = EnemyObjectTilemap.get_used_cells()

	var index=0
	for n in enemySpawnLocations:
		var tile:TileData = EnemyObjectTilemap.get_cell_tile_data(enemySpawnLocations[index])
		
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
		var SpawnPositionInMapCoordinates= EnemyObjectTilemap.local_to_map(EnemyObjectTilemap.to_local(enemiesToSpawnList[index].spawnLocation))
		var spawnPointInLocalCoords= EnemyObjectTilemap.map_to_local(SpawnPositionInMapCoordinates) 
		
		var spawnPosLocalCoords=EnemyObjectTilemap.map_to_local(enemiesToSpawnList[index].spawnLocation)
		
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
		var spawnpos:Vector2i=EnemyObjectTilemap.local_to_map(EnemyObjectTilemap.to_local(n.GetLocalSpawnPosition()))
		#Converts CURRENT position into tilemap coordinates
		var newpos:Vector2i=EnemyObjectTilemap.local_to_map(EnemyObjectTilemap.to_local(n.position))

		if spawnpos!=newpos:
			#MoveTileToNewPos(spawnpos,newpos)
			enemiesToSpawnList[index].spawnLocation=newpos
		
		pass
		index+=1
	return enemiesToSpawnList
	pass
	
func MoveTileToNewPos(oldpos:Vector2,newpos:Vector2):
	var tile_map_layer = 0 
	var tile_map_cell_position = oldpos 
	var tile_data = EnemyObjectTilemap.get_cell_tile_data(tile_map_cell_position)
	if tile_data: 
		var tile_map_cell_source_id = EnemyObjectTilemap.get_cell_source_id(tile_map_cell_position); 
		var tile_map_cell_atlas_coords = EnemyObjectTilemap.get_cell_atlas_coords(tile_map_cell_position) 
		var tile_map_cell_alternative = EnemyObjectTilemap.get_cell_alternative_tile(tile_map_cell_position) 
		var new_tile_map_cell_position = newpos
		EnemyObjectTilemap.set_cell(new_tile_map_cell_position, tile_map_cell_source_id, tile_map_cell_atlas_coords, tile_map_cell_alternative)
			
		
