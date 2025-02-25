extends Resource
class_name abstract_SoundEffectSetting

enum SoundEffectEnum
{ 
	PLAYER_JUMP,
	PLAYER_LAND,
	PLAYER_JUMP_MIDAIR,
	PLAYER_FOOTSTEP_ONE,
	PLAYER_FOOTSTEP_TWO,
	#4
	AMBIENCE_SURFACE,
	BLOCK_DESTROY,
	ORE_GRABBED,
	ORE_LAND,
	MUSIC_HOME,
	PLAYER_HURT,
	#10
	HOME_MENU_UP,
	HOME_MENU_DOWN,
	HOME_MENU_PURCHASE_YES,
	HOME_MENU_PURCHASE_NO,
	
	PLAYER_DRILL_AIR,
	PLAYER_DRILL_SOLID,
	PLAYER_DRILL_BREAKABLE,
	#17
	
	FLOWER_LOOP,
	FALLBLOCK_LAND,
	PLAYER_GRAB_FLOWER,
	HOME_GIVEORE_RISER,
	HOME_GIVEORE_POFF
	#22
}

@export_range(0,10) var limit:int=5
#add various variables here! 
@export var type:SoundEffectEnum
@export var sound_effect: AudioStreamWAV
@export_range (-40,20) var volume=0
@export_range(0.0,1.0,.01) var pitch_randomness=0.0 #stolen from internwet

enum AudioBusEnum {Master,Sfx,Music,Ambience}
@export var audioBus:AudioBusEnum

var audio_count:int=0
#Source: https://www.youtube.com/watch?v=Egf2jgET3nQ Make sure to credit if u use it

func has_open_limit()->bool:
	return audio_count<limit

func on_audio_finished():
	change_audio_count(-1)
	pass

func change_audio_count(change:int):
	audio_count=max(0,audio_count+change)
