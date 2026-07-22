extends Camera2D

var initialOffset:float=200
var timeToLerp:float=1
var lerpTimer:float=0
var lerpTarget:Vector2
var lerpStart:Vector2
var islerping=false
var lerpWithEase:bool=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !islerping:
		return
	
	lerpTimer+=delta
	var progress:float = lerpTimer/timeToLerp
	
	var easedProgress:float
	if lerpWithEase:
		easedProgress=ease(progress,0.4)
	else:
		ease(progress,1)
	self.position=lerp(lerpStart,lerpTarget,easedProgress)
	if lerpTimer>= timeToLerp:
		islerping=false
	
	pass

func TrueEndingCameraLerp():
	
	lerpTimer=0
	timeToLerp=1
	lerpStart=position
	lerpTarget=position+Vector2(0,60)
	islerping=true
	lerpWithEase=false
	
	await get_tree().create_timer(1).timeout
	
	timeToLerp=1.5
	lerpStart=$"../cutscene_child_survives/cameraInitialLerpPos".global_position
	lerpTarget=$"../cutscene_child_survives/cameraTargetLerpPos".global_position
	lerpTimer=0
	islerping=true
	lerpWithEase=true
	

func CameraInitialLerp(_timeToLerp:float=timeToLerp):
	if _timeToLerp!=timeToLerp:
		timeToLerp=_timeToLerp
	
	lerpTarget=position	
	position=position+Vector2(0,initialOffset)
	lerpStart=position
	islerping=true
	
	
	pass
