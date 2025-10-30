extends Camera2D

var initialOffset:float=200
var timeToLerp:float=1
var lerpTimer:float=0
var lerpTarget:Vector2
var lerpStart:Vector2
var islerping=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !islerping:
		return
	
	lerpTimer+=delta
	var progress:float = lerpTimer/timeToLerp
	var easedProgress=ease(progress,0.4)
	self.position=lerp(lerpStart,lerpTarget,easedProgress)
	if lerpTimer>= timeToLerp:
		islerping=false
	
	pass

func CameraInitialLerp():
	lerpTarget=position	
	position=position+Vector2(0,initialOffset)
	lerpStart=position
	islerping=true
	
	
	pass
