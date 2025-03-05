extends Camera2D
class_name game_camera
@onready var Player: CharacterBody2D =$"../Player"

signal LerpFinished

enum states{ FOLLOWP,WAITING,LERPING}
var state:states
var startLerpPos:Vector2
var lerpDestinationPos:Vector2
var isLerping:bool=false
var lerpTime:float=1
var timeCounter:float=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	match state:
		states.WAITING:
			
			pass
		states.LERPING:
			progressLerp(_delta)

		states.FOLLOWP:
			followPlayer()
			
	pass

func SetFollowPlayer(follow:bool):
	if follow:
		state=states.FOLLOWP
	else:
		state=states.WAITING

func StartNewLerp(_destination:Vector2, _time:float):
	state=states.LERPING
	if _time>0:
		lerpTime=_time
	else:
		self.global_position=_destination
		state=states.WAITING
		LerpFinished.emit()
		return
	lerpDestinationPos=_destination
	startLerpPos=position
	timeCounter=0

	
	
	pass

func progressLerp(delta:float):
	
	timeCounter+=delta
	var progress:float = timeCounter/lerpTime
	
	self.position=lerp(startLerpPos,lerpDestinationPos,progress)
	if timeCounter>= lerpTime:
		LerpFinished.emit()
		state=states.WAITING
	
	
	#position.cubic_interpolate()
	#position = startLerpPos.cubic_interpolate(lerpDestinationPos, startLerpPos,lerpDestinationPos,progress)
	
	
	
	#transform = $Position1.transform.interpolate_with($Position2.transform, t)
	
	pass
	
func lerp(a,b,t):
	return (1 - t) * a + t * b
	
func followPlayer():
	self.position = Player.position

	
