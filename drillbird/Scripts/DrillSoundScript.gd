extends AudioStreamPlayer

@export var sound_air:AudioStreamWAV
@export var sound_breakable:AudioStreamWAV
@export var sound_solid:AudioStreamWAV

@onready var audiostream=$"."

var currentTerrain:abstract_terrain_info

@export var maxPitch=1
@export var minPitch=0.8

var playerdrill:bool=false
var materialchangecallint:int=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass
	
func SetDrillProgress(progress:float):
	audiostream.pitch_scale=minPitch+(maxPitch-minPitch)*progress

func StopDrilling():
	audiostream.stop()
	currentTerrain=null
	pass

func MaterialChange(terrain:abstract_terrain_info):
	materialchangecallint+=1
	if currentTerrain!=terrain:
		audiostream.pitch_scale=minPitch
		
	
	if terrain==null: #This has not yet been implemented - but I think we should in the future
		if !audiostream.playing or audiostream.stream!=sound_air:
			audiostream.stream=sound_air
			audiostream.volume_db=-30
			audiostream.play()
		return


	if terrain.terrainIdentifier>=1: #Sand or higher hardness
		audiostream.stream=sound_breakable
		audiostream.volume_db=-15
		audiostream.play()
	
	if terrain.terrainIdentifier<=0: #Solid
		audiostream.stream=sound_solid
		audiostream.volume_db=-15
		audiostream.play()

	
	pass

func _on_sound_finished() -> void:

	audiostream.play()	
	pass # Replace with function body.


func _on_tile_crack_material_changed(terrain: abstract_terrain_info) -> void:
	MaterialChange(terrain)
	
	pass # Replace with function body.


func _on_tile_crack_player_is_doing_drill_action_change(drilling: bool) -> void:
	playerdrill=drilling
	
	if drilling:
		MaterialChange(currentTerrain)
	else:
		StopDrilling()
	
	pass # Replace with function body.
