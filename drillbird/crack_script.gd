extends Node2D

var diggingTime=0.0

@onready var diggingCountdown: Timer =$DiggingCountdown
@onready var tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")
@onready var cracksprite: Sprite2D = $cracksprite

 
var affectedTile:TileData
var drillPosition:Vector2i
var isDrillingActive:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _on_player_new_tile_crack(drill_position:Vector2i) -> void:
	NewTarget(drill_position)



func NewTarget(drill_position:Vector2i):
		
	drillPosition=drill_position
	var cellLocation = tilemap.local_to_map(tilemap.to_local(drillPosition))
	affectedTile= tilemap.get_cell_tile_data(cellLocation)
	
	print_debug("New Target!")


	cracksprite.show()

	var digtime=3.0
	var diggable=true
	
	match affectedTile.terrain:
		0: #dirt
			digtime=1
		1: #sand
			digtime=0.5
		2: #solid 
			diggable = false
	
	if(diggable):
		diggingCountdown.start(digtime)
	
	#else play particle effects 
	
	self.position = drillPosition
	#todo: align this
	
	#var tile: TileData =tilemap.get_cell_tile_data(tilemap.local_to_map( tilemap.to_local( location)))

	
	pass

func abortDig():
	diggingCountdown.stop()
	isDrillingActive=false
	cracksprite.hide()
	

func _on_digging_countdown_timeout() -> void:
	
	tilemap.set_cell(tilemap.local_to_map(tilemap.to_local(drillPosition)),-1,Vector2i(-1,-1),-1)
	cracksprite.hide()
	diggingCountdown.wait_time=100
	isDrillingActive=false


	pass # Replace with function body.


func _on_player_player_stopped_drilling_tile() -> void:
	abortDig()

	pass # Replace with function body.
