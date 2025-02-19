extends AudioStreamPlayer2D
class_name hub_music_player

@onready var player_idle=$music_idle
@onready var player_dreaming=$music_dream
var volume_idle:float=0
var volume_dream:float=0

@export var minVolume=-80
@export var maxVolume=0
@export var volumeChangeSpeed=20

@export var mus_idle_beginning:AudioStreamWAV
@export var mus_idle_end:AudioStreamWAV


enum musicStates{IDLE, DREAM, FINALE}
var musicState:musicStates=musicStates.IDLE

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	finished.connect(play)
	GlobalVariables.SetupComplete.connect(SetupComplete)

	pass # Replace with function body.

func SetupComplete():
	UpdateIdleMusic()
	SetState(hub_music_player.musicStates.IDLE)

	

func UpdateIdleMusic():
	
	if GlobalVariables.totalExperienceGained>200:
		player_idle.stream=mus_idle_end
	else:
		player_idle.stream=mus_idle_beginning
	
	player_idle.play()
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if musicState==musicStates.IDLE:
		if volume_idle<maxVolume:
			volume_idle+=delta*volumeChangeSpeed
	else:
		if volume_idle > minVolume:
			volume_idle-=delta*volumeChangeSpeed
	
	player_idle.volume_db=volume_idle
	
	if musicState==musicStates.DREAM:
		if volume_dream< maxVolume:
			volume_dream+=delta*volumeChangeSpeed
	else:
		if volume_dream > minVolume:
			volume_dream-=delta*volumeChangeSpeed
	player_dreaming.volume_db=volume_dream
	
	pass

func SetState(_state:musicStates):
	if musicState==_state:
		return
	musicState=_state
	
	match musicState:
		musicStates.IDLE:
			pass
		musicStates.DREAM:
			player_dreaming.play(0)
			
			pass
		musicStates.FINALE:
			pass
	pass
