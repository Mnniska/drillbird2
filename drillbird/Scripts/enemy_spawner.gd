extends Node2D
@export var potentialEnemyStrings:Array[String]

var spawnedEnemy
@onready var enemyTilemap:TileMapLayer=$"../Tilemap_Enemies"

var spawnedEnemies:Array[Node2D]

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		SpawnAllEnemies()
	
	if Input.is_action_just_pressed("drill"):
		DespawnAndSaveEnemyPositions()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func SpawnAllEnemies():
	
	spawnedEnemies.clear()
	var enemySpawnLocations = enemyTilemap.get_used_cells()

	var index=0
	for n in enemySpawnLocations:
		var tile:TileData = enemyTilemap.get_cell_tile_data(enemySpawnLocations[index])
		
		
		var enemy = load(potentialEnemyStrings[tile.get_custom_data("enemy_type")])
		var node = enemy.instantiate()
		spawnedEnemies.append(node)		
		
		var globalSpawnPos= enemyTilemap.map_to_local(enemySpawnLocations[index]) 
		var localSpawnPos = self.to_local(globalSpawnPos)
		
		node.transform.origin = localSpawnPos
		add_child(node)
		index+=1
			
	pass

func SpawnEnemy(pos:Vector2,enemyNumber:int):
	


	pass

func DespawnAndSaveEnemyPositions():
	for n in spawnedEnemies:
		
		#This SHOULD return the enemy position in tilemap coordinates
		var spawnpos:Vector2=enemyTilemap.local_to_map(enemyTilemap.to_local(n.GetSpawnPosition()))
		var newpos:Vector2=enemyTilemap.local_to_map(enemyTilemap.to_local(n.position))
		
		if spawnpos!=newpos:
			
			MoveTileToNewPos(spawnpos,newpos)
			enemyTilemap.set_cell(spawnpos,-1,Vector2(-1,-1),-1)
			
			
		n.queue_free()
		
		pass
	
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
			
		
