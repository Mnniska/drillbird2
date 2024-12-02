extends Node2D

var diggingTime=0.0

@onready var diggingCountdown: Timer =$DiggingCountdown
@onready var tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")
@onready var cracksprite: Sprite2D = $cracksprite
@export var crack_sprites: Array[Texture]
 
var affectedTile:TileData
var drillPosition:Vector2i
var isDrillingActive:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if(isDrillingActive):
		var process = 1 - diggingCountdown.time_left/ diggingCountdown.wait_time 
		
		var test:float = (crack_sprites.size()-1)*process
		var currentSprite:int= roundf(test)
		if currentSprite>crack_sprites.size()-1:
			currentSprite=crack_sprites.size()-1
		cracksprite.texture=crack_sprites[currentSprite]

	
	
	

func _on_player_new_tile_crack(drill_position:Vector2i) -> void:
	NewTarget(drill_position)

func SetCrackPosition():
	cracksprite.show()
	var xpos = (ceil( drillPosition.x/16 )*16)+8
	var ypos = (ceil( drillPosition.y/16 )*16)+8
	
	
	var snappedPos = snapped(drillPosition, Vector2i(8, 8))
	
	self.position=Vector2i(xpos,ypos)
	#self.position = snappedPos
	

func NewTarget(drill_position:Vector2i):
		
	drillPosition=drill_position
	var cellLocation = tilemap.local_to_map(tilemap.to_local(drillPosition))
	affectedTile= tilemap.get_cell_tile_data(cellLocation)
	
	print_debug("New Target!")
	isDrillingActive=true
	



	var digtime=3.0
	var diggable=true
	
	match affectedTile.terrain:
		0: #dirt
			digtime=1
		1: #sand
			diggable = false
		2: #solid 
			digtime=0.2

	if(diggable):
		diggingCountdown.start(digtime)
		SetCrackPosition()
	
	#else play particle effects 
	

	
	#var tile: TileData =tilemap.get_cell_tile_data(tilemap.local_to_map( tilemap.to_local( location)))

	
	pass

func abortDig():
	diggingCountdown.stop()
	isDrillingActive=false
	cracksprite.hide()
	

func _on_digging_countdown_timeout() -> void:
	
	tilemap.set_cell(tilemap.local_to_map(tilemap.to_local(drillPosition)),-1,Vector2i(-1,-1),-1)
	cracksprite.hide()
	diggingCountdown.stop()
	isDrillingActive=false


	pass # Replace with function body.


func _on_player_player_stopped_drilling_tile() -> void:
	abortDig()

	pass # Replace with function body.
