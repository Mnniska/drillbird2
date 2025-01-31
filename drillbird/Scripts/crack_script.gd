extends Node2D
class_name crack_script
var diggingTime=0.0
signal PlayerDrillingMaterial(int:)
signal TileDestroyed(pos:Vector2i,tilemap:TileMapLayer)

#Signals for the sound 
signal playerIsDoingDrillActionChange(drilling:bool)
signal MaterialChanged(terrain:abstract_terrain_info)


var playerDrillingTile:bool=false

@onready var diggingCountdown: Timer =$DiggingCountdown
@onready var tilemap: TileMapLayer = get_parent().get_node("TilemapEnvironment")
@onready var OreSpawner=$"../TilemapOres"
@onready var DrillSoundPlayer=$DrillSoundPlayer
@onready var tileDestroyEffect=preload("res://Scenes/Effects/tile_destroy_effect.tscn")
@onready var Parent=$".."
@onready var ObserverRaycast=$ObserverRaycast


@onready var cracksprite: Sprite2D = $cracksprite
@export var crack_sprites: Array[Texture]

@export var minimumDigTime:float = 0.6
@export var GameTerrains:Array[abstract_terrain_info]:

	get: return GameTerrains
	set(value): 
		if value.size()>0:
			GameTerrains=value
	

var destroyed_tiles:Array[Vector2i]
var affectedTile:TileData
var cellLocation:Vector2i
var tileDrillingActive:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print_debug(str(GameTerrains.size()))
	
	pass # Replace with function body.

func _process(_delta: float) -> void:

	if(tileDrillingActive):
		var process = 1 - diggingCountdown.time_left/ diggingCountdown.wait_time 
		
		#Tells audio to go up in pitch
		DrillSoundPlayer.SetDrillProgress(process)
		
		#Set current sprite based on sprite amount & progress
		var crackSpriteInt:float = (crack_sprites.size()-1)*process
		var currentSprite:int= roundf(crackSpriteInt)
		if currentSprite>crack_sprites.size()-1:
			currentSprite=crack_sprites.size()-1
		cracksprite.texture=crack_sprites[currentSprite]

func SetPlayerIsDriling(drilling:bool):
	playerIsDoingDrillActionChange.emit(drilling)
		
	pass

func _on_player_new_tile_crack(drill_position:Vector2i) -> void:
	NewTarget(drill_position)



func NewTarget(drill_position:Vector2i):
	playerDrillingTile=true
	#StartedDrilling.emit()
	
	cellLocation = tilemap.local_to_map(tilemap.to_local(drill_position))
	affectedTile= tilemap.get_cell_tile_data(cellLocation)
	
	tileDrillingActive=true
	
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


func GetHealthForTerrain(terrain:int):
	for n in GameTerrains:
		if n.terrainIdentifier==terrain:
			return n.terrainHP
	
 
	push_error("Gave an invalid int to terrain list - have you added all of the terrains to the TileCrack Game Terrains array?")
	return -1
	pass

func abortDig():
	#StoppedDrilling.emit()
	diggingCountdown.stop()
	tileDrillingActive=false
	cracksprite.hide()
	MaterialChanged.emit(null)
	

func GetDestroyedTiles():
	return destroyed_tiles
	
func OnLoadDestroyDugTiles(tiles:Array[Vector2i]):
	destroyed_tiles=tiles
	
	for n in destroyed_tiles:
		DestroyTile(n,false)
	
		if OreSpawner.get_cell_tile_data(n):
			OreSpawner.set_cell(n,-1,Vector2i(-1,-1),-1)

		
		pass
	
	pass

func DestroyTileWithGlobalPosition(global_pos:Vector2,playEffect:bool):
	var tilemapPos= tilemap.local_to_map(tilemap.to_local(global_pos))
	return DestroyTile(tilemapPos,playEffect)
	
	pass

func DestroyTile(position_in_grid:Vector2i,playEffect:bool):
	
	var t =tilemap.get_cell_tile_data(position_in_grid)
	if t==null or t.terrain==0:
		return false
	
	if playEffect:
		SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.BLOCK_DESTROY)

		for n in GameTerrains:
			if n.terrainIdentifier==tilemap.get_cell_tile_data(position_in_grid).terrain:
				SpawnDestroyEffect(position_in_grid,n)
	
	var cells:Array[Vector2i]
	cells.append(position_in_grid)
	tilemap.set_cells_terrain_connect(cells, 0, 0,false)
	tilemap.set_cell (position_in_grid,-1,Vector2i(-1,-1),-1)
	tilemap.set_cells_terrain_connect(cells, 0, -1,false)
	TileDestroyed.emit(position_in_grid,tilemap)

		#handle ore spawning
	OreSpawner.TrySpawnOreFromEnvironment(position_in_grid)

	destroyed_tiles.append(position_in_grid)
	CheckObservers(position_in_grid)
	return true

func _on_player_player_stopped_drilling_tile() -> void:
	if playerDrillingTile:
		playerDrillingTile=false
		abortDig()

	pass # Replace with function body.
	
func _on_player_signal_player_drilling(drilling: bool) -> void:
	SetPlayerIsDriling(drilling)
	
	pass # Replace with function body.

func _on_digging_countdown_timeout() -> void:
	
	#Remove target cell and make neighbors reconnect to one another
#	StoppedDrilling.emit() #This is not true - this is only TILE CRACKS
	
	DestroyTile(cellLocation,true)
	
	cracksprite.hide()
	diggingCountdown.stop()
	tileDrillingActive=false

func SpawnDestroyEffect(position:Vector2i,terrain:abstract_terrain_info):
	
	#var globalpos:Vector2=Parent.to_l( tilemap.map_to_local(position))
	
	var node:AnimatedSprite2D= tileDestroyEffect.instantiate()
	node.animation_finished.connect(node.queue_free)
	var pos=to_local(tilemap.map_to_local(position))
	node.transform.origin=to_global(pos)
	node.modulate=terrain.DestroyParticleColor
	Parent.add_child(node)
	#node.global_position=globalpos
	
	




func CheckObservers(location:Vector2i):
	var pos=to_local(tilemap.map_to_local(location))
	ObserverRaycast.position=pos
	ObserverRaycast.force_raycast_update()
	
	var objects_collide = [] #The colliding objects go here.
	while ObserverRaycast.is_colliding():
		var obj = ObserverRaycast.get_collider() #get the next object that is colliding.
		objects_collide.append( obj ) #add it to the array.
		ObserverRaycast.add_exception( obj ) #add to ray's exception. That way it could detect something being behind it.
		ObserverRaycast.force_raycast_update() #update the ray's collision query.

#after all is done, remove the objects from ray's exception.
	for obj in objects_collide:
		ObserverRaycast.remove_exception( obj )
		obj.ObservedBlockDestroyed()
