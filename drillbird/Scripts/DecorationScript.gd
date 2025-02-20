extends TileMapLayer
@onready var decotilemap=$"."
@onready var tilemap_environment=$"../TilemapEnvironment"
@onready var tileDestroyer=$"../TileCrack"
var observers:Array[abstract_decoration]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GenerateTilemapObservers()
	#tileDestroyer.TileDestroyed.connect(CheckDecorationDependenciesForPosition)
	
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


func CheckDecorationDependenciesForPosition(pos:Vector2i,tilemap:TileMapLayer):
	for n in isAnyObserverAtPosition(pos):
		RemoveCell(n)
	
	

func isAnyObserverAtPosition(pos:Vector2i):
	
	var affectedObservers:Array[abstract_decoration]
	
	for n in observers:
		if n.active:
			if pos.y==n.GetDependencyPosition().y:
				if pos.x==n.GetDependencyPosition().x:
					affectedObservers.append(n)
		
	return affectedObservers
	

func GenerateTilemapObservers():
	#Should only be done if there is no save data
	#Creates a new abstract_enemy per spawn location and adds it to a list
	observers.clear()
	var decorationLocations = decotilemap.get_used_cells()

	var index=0
	for n in decorationLocations:
		var tile:TileData = decotilemap.get_cell_tile_data(n)
		var dependencyV = tile.get_custom_data("dir_dependency")
		
		#If the deco does not have a deco dependency - just let it be
		if dependencyV != Vector2i(0,0):
			
			var newObserver=abstract_decoration.new()
			newObserver.dependencyVector=dependencyV
			newObserver.deco_position=decorationLocations[index]
			
			#if new cell has a valid dependency tile, add it to the list. If not - remove it
			if IsDecorationValid(newObserver):
				observers.append(newObserver)
			else:
				RemoveCell(newObserver)

		index+=1
			
func IsDecorationValid(tileToCheck:abstract_decoration):
	if tilemap_environment.get_cell_tile_data(tileToCheck.GetDependencyPosition())==null:
		return false
	else:
		return true
		
	#var tile:TileData=

func RemoveCell(tile:abstract_decoration):
	
	decotilemap.set_cell (tile.deco_position,-1,Vector2i(-1,-1),-1)
	tile.active=false
	
