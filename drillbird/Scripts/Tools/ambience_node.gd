extends Node2D

var player:Node2D

@onready var audioplayer=$AudioStreamPlayer2D
@export var AmbiencesToPlay:Array[AudioStreamWAV]

#Variables to make sound player follow player pos
var sizebuffer=500
var boundingBoxBegin:Vector2
var boundingBoxEnd:Vector2
var rectSize:Vector2
var average:float

func _ready() -> void:
	
	
	rectSize = $AffectedArea/CollisionShape2D.shape.size
	average = (rectSize.x/2+rectSize.y/2)/2
	boundingBoxBegin =global_position-Vector2(rectSize.x/2,rectSize.y/2)
	boundingBoxEnd =global_position+Vector2(rectSize.x/2,rectSize.y/2)
	
	audioplayer.stream=GetAudioStream()
	GlobalVariables.SetupComplete.connect(SetupComplete)

func SetupComplete():
	player=GlobalVariables.PlayerController
	audioplayer.play()
	pass
	
func AmbienceFinishedPlaying():
	audioplayer.stream=GetAudioStream()
	audioplayer.play()
	
	
func GetAudioStream():
	var amount=float(AmbiencesToPlay.size())
	var seed = randf()
	var counter:float=0
	for ambience in AmbiencesToPlay:
		counter+=1/amount
		if counter>seed:
			return ambience
	
	#failsafe	
	return AmbiencesToPlay[0]
	


func SetAmbienceActive(_active):
	
	if _active:
		audioplayer.play()
	else:
		audioplayer.stop()
	pass


#Tools for sensing whether player is in the area or not. I've added delays to circumvent area2Ds incorrectly registering extra exits/entrances
func _process(delta: float) -> void:
	
	if player==null:
		return
	
	while global_position.distance_to(player.global_position)>average+sizebuffer:
		await get_tree().create_timer(3).timeout

	if player!=null:
		var playerpos=player.global_position
		var posx=playerpos.x
		var posy=playerpos.y
		if playerpos.x<boundingBoxBegin.x:
			posx=boundingBoxBegin.x
		if playerpos.x>boundingBoxEnd.x:
			posx=boundingBoxEnd.x
			
		if playerpos.y>boundingBoxEnd.y:
			posy=boundingBoxEnd.y
		if playerpos.y<boundingBoxBegin.y:
			posy=boundingBoxBegin.y
			
		audioplayer.global_position=Vector2(posx,posy)
