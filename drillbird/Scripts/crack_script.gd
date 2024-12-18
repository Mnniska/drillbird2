extends Node2D

var diggingTime=0.0
signal PlayerDrillingSolid
@onready var diggingCountdown: Timer =$DiggingCountdown
@onready var tilemap: TileMapLayer = get_parent().get_node("TilemapEnvironment")
@onready var oreTilemap: TileMapLayer = get_parent().get_node("TilemapOres")

@onready var cracksprite: Sprite2D = $cracksprite
@export var crack_sprites: Array[Texture]
@export var oreRegions: Array[abstract_ore_region]
@export var minimumDigTime:float = 0.6
@export var GameTerrains:Array[abstract_terrain_info]

var affectedTile:TileData
var cellLocation:Vector2i
var isDrillingActive:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(_delta: float) -> void:
	if(isDrillingActive):
		var process = 1 - diggingCountdown.time_left/ diggingCountdown.wait_time 
		
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
		
	cellLocation = tilemap.local_to_map(tilemap.to_local(drill_position))
	affectedTile= tilemap.get_cell_tile_data(cellLocation)
	
	print_debug("New Target!")
	isDrillingActive=true
	
	var digtime=3.0
	var diggable=true
	
	if affectedTile!=null:
		var tilehealth=0
		#<0 indicates player is drilling a solid tile
		if GetHealthForTerrain(affectedTile.terrain)>0:
			#get the tile's health and reduce it by player upgrade lvl
			tilehealth =GetHealthForTerrain(affectedTile.terrain)-GlobalVariables.upgradeLevel_drill
			if tilehealth<1&&tilehealth>=0:
				tilehealth=0.5
			digtime= tilehealth*minimumDigTime

		else:
			diggable = false
		

		if(diggable):
			diggingCountdown.start(digtime)
			SetCrackPosition(drill_position)
		else:
			PlayerDrillingSolid.emit()
			print_debug("Solid!!")
	
	#else play particle effects 
	#var tile: TileData =tilemap.get_cell_tile_data(tilemap.local_to_map( tilemap.to_local( location)))

	
	pass

func GetHealthForTerrain(terrain:int):
	for n in GameTerrains:
		if n.terrainIdentifier==terrain:
			return n.terrainHP
	
	return -1 
	push_error("Gave an invalid int to terrain list - have you added all of the terrains to the TileCrack Game Terrains array?")
	pass

func abortDig():
	diggingCountdown.stop()
	isDrillingActive=false
	cracksprite.hide()
	

func _on_digging_countdown_timeout() -> void:
	
	#Remove target cell and make neighbors reconnect to one another
	var cells:Array[Vector2i]
	cells.append(cellLocation)
	tilemap.set_cells_terrain_connect(cells, 0, 0,false)
	tilemap.set_cell (cellLocation,-1,Vector2i(-1,-1),-1)
	tilemap.set_cells_terrain_connect(cells, 0, -1,false)

#● Vector2i get_neighbor_cell(coords: Vector2i, neighbor: TileSet.CellNeighbor) const
	
	cracksprite.hide()
	diggingCountdown.stop()
	isDrillingActive=false
	
	#handle ore spawning
	var cell = oreTilemap.get_cell_tile_data(cellLocation)
	if cell!=null: #is there an ore tile on top of destroyed tile?
		oreTilemap.set_cell(cellLocation,-1,Vector2i(-1,-1),-1)
		
		var oreRegion:int=cell.get_custom_data("ore_region")
		
		
		#Todo: This should be based on ore rarity determined by area player is in
		var newOre=null
		for n in oreRegions:
			if n.oreRegionID==oreRegion:
				newOre=n.GetOreToSpawn()
		if newOre==null:
			push_error("Crack script was unable to find a good ore!")
		
		var scene = load("res://Scenes/Object_Ore.tscn") # Will load when the script is instanced.
		var node = scene.instantiate()
		
		node.transform.origin = position

		get_parent().add_child(node)
		node.SetOreType(newOre)

	pass # Replace with function body.


func _on_player_player_stopped_drilling_tile() -> void:
	abortDig()

	pass # Replace with function body.
