extends Node2D

var amountOfEchoZonesPlayerIsIn:int=0

var playerIsEchoing:bool=false

func _ready() -> void:
	var reverbzones:Array[Node]=get_children()
	
	for zone in reverbzones:
		var collider:Area2D=zone
		collider.body_entered.connect(PlayerEntersAZone)
		collider.body_exited.connect(PlayerLeavesAZone)
		
func PlayerEntersAZone(_body:Node2D):
	amountOfEchoZonesPlayerIsIn+=1
	UpdateEchoing()

func PlayerLeavesAZone(_body:Node2D):
	amountOfEchoZonesPlayerIsIn-=1
	UpdateEchoing()

func UpdateEchoing():
	if amountOfEchoZonesPlayerIsIn>0 and !playerIsEchoing:
		playerIsEchoing=true
		SoundManager.SetReverbActive(true)

	if amountOfEchoZonesPlayerIsIn<=0 and playerIsEchoing:
		playerIsEchoing=false
		SoundManager.SetReverbActive(false)
