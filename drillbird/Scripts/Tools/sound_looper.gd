extends Node2D
class_name sound_looper
@onready var audioPlayer=$AudioStreamPlayer2D
@export var soundEffect:abstract_SoundEffectSetting
var loopSound:bool=true

func _ready() -> void:
	SetupCommonSoundSettings(soundEffect,audioPlayer)
	audioPlayer.finished.connect(SoundFinishedPlaying)

func Play():
	if !audioPlayer.playing:
		audioPlayer.play()
	
	
	pass

func Stop():
	
	audioPlayer.stop()
	
	pass

func SetPitch(pitch:float):
	audioPlayer.pitch_scale=pitch
	pass
	
func SoundFinishedPlaying():
	if loopSound:
		audioPlayer.play()
	pass


func SetupCommonSoundSettings(soundEffectSetting:abstract_SoundEffectSetting,audio:AudioStreamPlayer2D):
	audio.stream=soundEffectSetting.sound_effect
	audio.volume_db=soundEffectSetting.volume
	audio.pitch_scale+=randf_range(-soundEffectSetting.pitch_randomness,soundEffectSetting.pitch_randomness)
	audio.bus=soundEffectSetting.AudioBusEnum.keys()[soundEffectSetting.audioBus]
	return audio
