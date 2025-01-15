extends Node2D

@export var SOUND_EFFECTS:Array[abstract_SoundEffectSetting]


var soundEffectDict={}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n : abstract_SoundEffectSetting in SOUND_EFFECTS:
		soundEffectDict[n.type]=n
	
	pass # Replace with function body.

func PlaySoundGlobal(sound:abstract_SoundEffectSetting.SoundEffectEnum):
	pass

func PlaySoundAtLocation(location:Vector2,type:abstract_SoundEffectSetting.SoundEffectEnum):
	
	if soundEffectDict.has(type):
		
		var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[type]
		
		if soundEffectSetting.has_open_limit(): #ensure the same effect can only play X times
			soundEffectSetting.change_audio_count(1)
			
			var new_2D_audio = AudioStreamPlayer2D.new()
			add_child(new_2D_audio)
			new_2D_audio.position=location
			new_2D_audio.stream=soundEffectSetting.sound_effect
			new_2D_audio.volume_db=soundEffectSetting.volume
			new_2D_audio.pitch_scale+=randf_range(-soundEffectSetting.pitch_randomness,soundEffectSetting.pitch_randomness)
			
			new_2D_audio.finished.connect(soundEffectSetting.on_audio_finished) 
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			
			new_2D_audio.play()
		
		pass
	
	else:
		push_error("Attempted to play an invalid sound!")
	
	pass
