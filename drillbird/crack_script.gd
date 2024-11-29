extends Node2D

var diggingTime=0.0

@onready var diggingCountdown: Timer =$DiggingCountdown
@onready var tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")

var affectedTile:TileData
var drillPosition:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func SpawnSetup(tile: TileData, globalPosition: Vector2i):
	affectedTile=tile
	drillPosition=globalPosition

	var digtime=3.0
	var diggable=true
	
	match tile.terrain:
		0: #dirt
			digtime=3.0
		1: #sand
			digtime=0.5
		2: #solid 
			diggable = false
	
	if(diggable):
		diggingCountdown.start(digtime)
	
	#else play particle effects 
	
	
	#var tile: TileData =tilemap.get_cell_tile_data(tilemap.local_to_map( tilemap.to_local( location)))
	
	
	# 0 = sand
	# 1 = solid 
	# 2 = dirt
	
	diggingCountdown.start(digtime)
	
	pass

func abortDig():
	diggingCountdown.stop()
	self.queue_free()
	

func _on_digging_countdown_timeout() -> void:
	
	#destroy block
	#var globalPosition=self.global_position
	tilemap.set_cell(tilemap.local_to_map(tilemap.to_local(drillPosition)),-1,Vector2i(-1,-1),-1)
	
	self.queue_free()

	pass # Replace with function body.
