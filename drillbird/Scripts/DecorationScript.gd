extends TileMapLayer
@onready var decotilemap=$"."
var observers:Array[Node2D]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#TODO:
	"""
	1. Create abstract deco tile
	- position
	-dependency direction 
	
	2. When a tile breaks, check if location is close to any of the tiles in the list
	1. start with y
	2. then check x, for efficiency. 
	
	If tile is destroyed, destroy it
	
	3. At startup, after generation deco tiles, double check the target they're on is valid, remove if not
	"""
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func GenerateTilemapObservers():
	#Should only be done if there is no save data
	#Creates a new abstract_enemy per spawn location and adds it to a list
	observers.clear()
	var decorationLocations = decotilemap.get_used_cells()

	var index=0
	for n in decorationLocations:
		var tile:TileData = decotilemap.get_cell_tile_data(decorationLocations[index])
		var newEnemy=abstract_enemy.new()
		newEnemy.type=tile.get_custom_data("enemy_type")
		newEnemy.spawnLocation=decorationLocations[index]
		observers.append(newEnemy)
		index+=1
			
