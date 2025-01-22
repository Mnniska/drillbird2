extends AudioStreamPlayer

@export var sound_air:AudioStreamWAV
@export var sound_breakable:AudioStreamWAV
@export var sound_solid:AudioStreamWAV

@onready var audiostream=$"."

var currentTerrain:abstract_terrain_info

@export var maxPitch=1
@export var minPitch=0.8


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
	pass

func MaterialChange(terrain:abstract_terrain_info):
	
	if currentTerrain!=terrain:
		audiostream.pitch_scale=minPitch
		
	
	if terrain==null: #This has not yet been implemented - but I think we should in the future
		audiostream.stream=sound_air
		audiostream.play()
		return


	if terrain.terrainIdentifier>=1: #Sand or higher hardness
		audiostream.stream=sound_breakable
		audiostream.play()
	
	if terrain.terrainIdentifier<=0: #Solid
		audiostream.stream=sound_solid
		audiostream.play()

	
	pass

func _on_sound_finished() -> void:

	audiostream.play()	
	pass # Replace with function body.




func _on_tile_crack_stopped_drilling() -> void:
	StopDrilling()
	pass # Replace with function body.


func _on_tile_crack_material_changed(terrain: abstract_terrain_info) -> void:
	MaterialChange(terrain)
	
	pass # Replace with function body.
