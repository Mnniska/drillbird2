extends Node2D
@export var potentialEnemyStrings:Array[String]


@onready var enemyTilemap:TileMapLayer=$"../Tilemap_Enemies"



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
	
	GenerateEnemySpawnsFromTilemap()

	SpawnAllEnemies()
	enemyTilemap.hide()
	#enemyTilemap.hide()
	pass

func LoadEnemySpawns(spawns:Array[abstract_enemy]):
	
	enemiesToSpawnList.clear()
	for n in spawns:
		enemiesToSpawnList.append(n)
	
	pass

func GenerateEnemySpawnsFromTilemap():
	#Should only be done if there is no save data
	#Creates a new abstract_enemy per spawn location and adds it to a list
	enemiesToSpawnList.clear()
	var enemySpawnLocations = enemyTilemap.get_used_cells()

	var index=0
	for n in enemySpawnLocations:
		var tile:TileData = enemyTilemap.get_cell_tile_data(enemySpawnLocations[index])
		var newEnemy=abstract_enemy.new()
		newEnemy.type=tile.get_custom_data("enemy_type")
		newEnemy.spawnLocation=enemySpawnLocations[index]
		enemiesToSpawnList.append(newEnemy)
		index+=1
			
	return enemiesToSpawnList
	

func SpawnAllEnemies():
	
	#Spawns all enemies in the EnemiesToSpawn list. This list is loaded from savefile or setup during first play
	
	var index=0
	for n in enemiesToSpawnList:
		
		var enemy = load(potentialEnemyStrings[enemiesToSpawnList[index].type])
		var node = enemy.instantiate()
		spawnedEnemies.append(node)	
		print_debug("Spawnpos: "+str(enemiesToSpawnList[index].spawnLocation))

		var globalSpawnPos= enemyTilemap.map_to_local(enemiesToSpawnList[index].spawnLocation) 
		var localSpawnPos = self.to_local(globalSpawnPos)
		
		
		node.transform.origin = localSpawnPos
		add_child(node)
		index+=1
			
	pass


func UpdateEnemySpawnLocations():
	
	var index=0
	for n in spawnedEnemies:
		
		#This SHOULD return the enemy position in tilemap coordinates
		#var spawnpos:Vector2i=enemiesToSpawnList[index].spawnLocation
		var spawnpos2:Vector2i=n.GetSpawnPosition()
		
		
		var spawnpos:Vector2i=enemyTilemap.local_to_map(enemyTilemap.to_local(n.GetSpawnPosition()))
		var newpos:Vector2i=enemyTilemap.local_to_map(enemyTilemap.to_local(n.position))
		#Convert spawnpos to tilemap coordinates 
		
		if spawnpos!=newpos:
			
			#Updates enemy new spawn position according to its current position
			#Assumes enemiestospawn list is same length as spawned enemies
			
			MoveTileToNewPos(spawnpos,newpos)
			enemiesToSpawnList[index].spawnLocation=n.position
			
		
		pass
		index+=1
	return enemiesToSpawnList
	pass
	
func MoveTileToNewPos(oldpos:Vector2,newpos:Vector2):
	var tile_map_layer = 0 
	var tile_map_cell_position = oldpos 
	var tile_data = enemyTilemap.get_cell_tile_data(tile_map_cell_position)
	if tile_data: 
		var tile_map_cell_source_id = enemyTilemap.get_cell_source_id(tile_map_cell_position); 
		var tile_map_cell_atlas_coords = enemyTilemap.get_cell_atlas_coords(tile_map_cell_position) 
		var tile_map_cell_alternative = enemyTilemap.get_cell_alternative_tile(tile_map_cell_position) 
		var new_tile_map_cell_position = newpos
		enemyTilemap.set_cell(new_tile_map_cell_position, tile_map_cell_source_id, tile_map_cell_atlas_coords, tile_map_cell_alternative)
			
		
