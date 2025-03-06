extends Node2D
class_name sound_manager

@export var SOUND_EFFECTS:Array[abstract_SoundEffectSetting]



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


	
func CreatePersistentSound(location:Vector2,type:abstract_SoundEffectSetting.SoundEffectEnum):

	#Creates a sound that will stay forever unless specifically deleted
	var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[0]
	var typeFound:bool=false
	for sound in SOUND_EFFECTS:
		if sound.type==type:
			typeFound=true
			soundEffectSetting=sound
			break
	if !typeFound:
		push_error("Attempted to play an invalid sound!")	

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



func PlaySoundGlobal(type:abstract_SoundEffectSetting.SoundEffectEnum,pitch:float=-1):

	var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[0]
	var typeFound:bool=false
	for sound in SOUND_EFFECTS:
		if sound.type == type:
			typeFound=true
			soundEffectSetting=sound
			break
	if !typeFound:
		push_error("Attempted to play an invalid sound!")	
		
	if soundEffectSetting.has_open_limit(): #ensure the same effect can only play X times
		soundEffectSetting.change_audio_count(1)
		
		var new_2D_audio = AudioStreamPlayer2D.new()
		add_child(new_2D_audio)
		new_2D_audio.global_position=GlobalVariables.MainSceneReferenceConnector.ref_camera.global_position
		
		new_2D_audio=SetupCommonSoundSettings(soundEffectSetting ,new_2D_audio)
		if pitch!=-1:
			new_2D_audio.pitch_scale=pitch
		new_2D_audio.finished.connect(soundEffectSetting.on_audio_finished) 
		new_2D_audio.finished.connect(new_2D_audio.queue_free)
		new_2D_audio.play()
		
	
	pass

func PlaySoundAtLocation(location:Vector2,type:abstract_SoundEffectSetting.SoundEffectEnum):
	
	var soundEffectSetting:abstract_SoundEffectSetting=SOUND_EFFECTS[0]
	var typeFound:bool=false
	for sound in SOUND_EFFECTS:
		if sound.type==type:
			typeFound=true
			soundEffectSetting=sound
			break
	if !typeFound:
		push_error("Attempted to play an invalid sound!")	
		
	
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
