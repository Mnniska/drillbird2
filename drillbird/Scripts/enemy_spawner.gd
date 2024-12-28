extends Node2D
@export var potentialEnemyStrings:Array[String]

var spawnedEnemy
@onready var enemyTilemap:TileMapLayer=$"../Tilemap_Enemies"

var spawnedEnemies:Array[abstract_enemy]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SpawnAllEnemies()
	pass # Replace with function body.

func SpawnAllEnemies():
	
	var enemySpawnLocations = enemyTilemap.get_used_cells()

	var index=0
	for n in enemySpawnLocations:
		var tile:TileData = enemyTilemap.get_cell_tile_data(enemySpawnLocations[index])
		
		
		var enemy = load(potentialEnemyStrings[tile.get_custom_data("enemy_type")])
		var node = enemy.instantiate()
		spawnedEnemies.append(node)		
		
		var globalSpawnPos= enemyTilemap.to_global(enemySpawnLocations[index]) 
		var localSpawnPos = self.to_local(globalSpawnPos)
		
		node.transform.origin = localSpawnPos
		add_child(node)
		
			
	pass

func SpawnEnemy(pos:Vector2,enemyNumber:int):
	


	pass

func DespawnEnemy():
	pass
