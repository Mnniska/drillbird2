extends Node2D

@export var SOUND_EFFECTS:Array[abstract_SoundEffectSetting]


var soundEffectDict={}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n : abstract_SoundEffectSetting in SOUND_EFFECTS:
		soundEffectDict[n.type]=n
	
	pass # Replace with function body.


	
func CreatePersistentSound(location:Vector2,type:abstract_SoundEffectSetting.SoundEffectEnum):

	#Creates a sound that will stay forever unless specifically deleted

	var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[type]

	var new_2D_audio = AudioStreamPlayer2D.new()
	add_child(new_2D_audio)
	new_2D_audio.position=location
	new_2D_audio.max_distance=16*20
	SetupCommonSoundSettings(soundEffectSetting,new_2D_audio)
	return new_2D_audio
	

func SetupCommonSoundSettings(soundEffectSetting:abstract_SoundEffectSetting,audio:AudioStreamPlayer2D):
	audio.stream=soundEffectSetting.sound_effect
	audio.volume_db=soundEffectSetting.volume
	audio.pitch_scale+=randf_range(-soundEffectSetting.pitch_randomness,soundEffectSetting.pitch_randomness)
	audio.bus=soundEffectSetting.AudioBusEnum.keys()[soundEffectSetting.audioBus]
	return audio
	
	pass

func PlaySoundGlobal(type:abstract_SoundEffectSetting.SoundEffectEnum):

	if soundEffectDict.has(type):
		
		var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[type]
		
		if soundEffectSetting.has_open_limit(): #ensure the same effect can only play X times
			soundEffectSetting.change_audio_count(1)
			
			var new_2D_audio = AudioStreamPlayer2D.new()
			add_child(new_2D_audio)
			new_2D_audio.global_position=GlobalVariables.PlayerController.global_position
			
			new_2D_audio=SetupCommonSoundSettings(soundEffectSetting ,new_2D_audio)

			new_2D_audio.finished.connect(soundEffectSetting.on_audio_finished) 
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			new_2D_audio.play()
		
		pass
	
	else:
		push_error("Attempted to play an invalid sound!")	
	pass

func PlaySoundAtLocation(location:Vector2,type:abstract_SoundEffectSetting.SoundEffectEnum):
	
	if soundEffectDict.has(type):
		
		var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[type]
		
		if soundEffectSetting.has_open_limit(): #ensure the same effect can only play X times
			soundEffectSetting.change_audio_count(1)
			
			var new_2D_audio = AudioStreamPlayer2D.new()
			add_child(new_2D_audio)
			new_2D_audio.position=location
			
			new_2D_audio=SetupCommonSoundSettings(soundEffectSetting ,new_2D_audio)

			new_2D_audio.finished.connect(soundEffectSetting.on_audio_finished) 
			new_2D_audio.finished.connect(new_2D_audio.queue_free)
			new_2D_audio.play()
		
		pass
	
	else:
		push_error("Attempted to play an invalid sound!")
	
	pass
