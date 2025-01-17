extends Node2D

var diggingTime=0.0
signal PlayerDrillingMaterial(int:)
signal TileDestroyed(pos:Vector2i)

#Signals for the sound 
signal StartedDrilling
signal StoppedDrilling
signal MaterialChanged(terrain:abstract_terrain_info)


@onready var diggingCountdown: Timer =$DiggingCountdown
@onready var tilemap: TileMapLayer = get_parent().get_node("TilemapEnvironment")
@onready var OreSpawner=$"../TilemapOres"
@onready var DrillSoundPlayer=$DrillSoundPlayer

@onready var cracksprite: Sprite2D = $cracksprite
@export var crack_sprites: Array[Texture]

@export var minimumDigTime:float = 0.6
@export var GameTerrains:Array[abstract_terrain_info]

var destroyed_tiles:Array[Vector2i]
var affectedTile:TileData
var cellLocation:Vector2i
var isDrillingActive:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:


	
	if(isDrillingActive):
		var process = 1 - diggingCountdown.time_left/ diggingCountdown.wait_time 
		
		#Tells audio to go up in pitch
		DrillSoundPlayer.SetDrillProgress(process)
		
		#Set current sprite based on sprite amount & progress
		var test:float = (crack_sprites.size()-1)*process
		var currentSprite:int= roundf(test)
		if currentSprite>crack_sprites.size()-1:
			currentSprite=crack_sprites.size()-1
		cracksprite.texture=crack_sprites[currentSprite]


func _on_player_new_tile_crack(drill_position:Vector2i) -> void:
	NewTarget(drill_position)

func SetCrackPosition(drillPosition:Vector2i):
	cracksprite.show()
	
	var xx =8
	if drillPosition.x<0:
		xx*=-1
	var xpos = (ceil( drillPosition.x/16 )*16)+xx
	
	var yy=8
	if drillPosition.y <0:
		yy*=-1
	var ypos = (ceil( drillPosition.y/16 )*16)+yy
		
	self.position=Vector2i(xpos,ypos)


func NewTarget(drill_position:Vector2i):
		
	StartedDrilling.emit()
	
	cellLocation = tilemap.local_to_map(tilemap.to_local(drill_position))
	affectedTile= tilemap.get_cell_tile_data(cellLocation)
	
	isDrillingActive=true
	
	var digtime=3.0
	var diggable=true
	
	if affectedTile!=null:
		
		#Lets game know what material the player is drilling
		for n in GameTerrains:
			if n.terrainIdentifier==affectedTile.terrain:
				MaterialChanged.emit(n) #emit signal that the player is drilling new mat
		
		var tilehealth=0
		#<0 indicates player is drilling a solid tile
		if GetHealthForTerrain(affectedTile.terrain)>0:
			#get the tile's health and reduce it by player upgrade lvl
			tilehealth =GetHealthForTerrain(affectedTile.terrain)-GlobalVariables.upgradeLevel_drill
			tilehealth = clampi(tilehealth,0,100)
			if tilehealth<1&&tilehealth>=0:
				tilehealth=0.5
			digtime= tilehealth*minimumDigTime

		else:
			diggable = false
		

		if(diggable):
			diggingCountdown.start(digtime)
			SetCrackPosition(drill_position)
	
	#else play particle effects 
	#var tile: TileData =tilemap.get_cell_tile_data(tilemap.local_to_map( tilemap.to_local( location)))

	
	pass

func GetHealthForTerrain(terrain:int):
	for n in GameTerrains:
		if n.terrainIdentifier==terrain:
			return n.terrainHP
	
 
	push_error("Gave an invalid int to terrain list - have you added all of the terrains to the TileCrack Game Terrains array?")
	return -1
	pass

func abortDig():
	StoppedDrilling.emit()
	diggingCountdown.stop()
	isDrillingActive=false
	cracksprite.hide()
	

func GetDestroyedTiles():
	return destroyed_tiles
	
func OnLoadDestroyDugTiles(tiles:Array[Vector2i]):
	destroyed_tiles=tiles
	
	for n in destroyed_tiles:
		DestroyTile(n)
	
		if OreSpawner.get_cell_tile_data(n):
			OreSpawner.set_cell(n,-1,Vector2i(-1,-1),-1)

		
		pass
	
	pass

func DestroyTile(position_in_grid:Vector2i):
	var cells:Array[Vector2i]
	cells.append(position_in_grid)
	tilemap.set_cells_terrain_connect(cells, 0, 0,false)
	tilemap.set_cell (position_in_grid,-1,Vector2i(-1,-1),-1)
	tilemap.set_cells_terrain_connect(cells, 0, -1,false)
	TileDestroyed.emit(position_in_grid)
	pass

func _on_digging_countdown_timeout() -> void:
	
	#Remove target cell and make neighbors reconnect to one another
	StoppedDrilling.emit() #This is not true - this is only TILE CRACKS
	DestroyTile(cellLocation)
	destroyed_tiles.append(cellLocation)

#● Vector2i get_neighbor_cell(coords: Vector2i, neighbor: TileSet.CellNeighbor) const
	
	cracksprite.hide()
	diggingCountdown.stop()
	isDrillingActive=false
	
	#handle ore spawning
	OreSpawner.TrySpawnOreFromEnvironment(cellLocation)

	pass # Replace with function body.


func _on_player_player_stopped_drilling_tile() -> void:
	abortDig()

	pass # Replace with function body.
