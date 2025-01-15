extends AudioStreamPlayer

@export var sound_air:AudioStreamWAV
@export var sound_breakable:AudioStreamWAV
@export var sound_solid:AudioStreamWAV

@onready var audiostream=$"."
enum MatEnum{AIR,SOLID,BREAKABLE}
var currentMat:MatEnum

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

func StartDrilling(mat:MatEnum):
	audiostream.pitch_scale=minPitch
	MaterialChange(mat)
	#audiostream.play()
	
	pass

func StopDrilling():
	audiostream.stop()
	pass

func MaterialChange(mat:MatEnum):
	
	match mat:
		MatEnum.AIR:
			audiostream.stream=sound_air
		
		MatEnum.SOLID:
			audiostream.stream=sound_solid
		MatEnum.BREAKABLE:
			audiostream.stream=sound_breakable
	audiostream.play()

	
	pass

func _on_sound_finished() -> void:

	audiostream.play()	
	pass # Replace with function body.


func _on_tile_crack_started_drilling() -> void:
	StartDrilling(MatEnum.BREAKABLE)
	pass # Replace with function body.


func _on_tile_crack_stopped_drilling() -> void:
	StopDrilling()
	pass # Replace with function body.
