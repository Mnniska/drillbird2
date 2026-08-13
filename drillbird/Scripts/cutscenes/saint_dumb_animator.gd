extends AnimatedSprite2D

@onready var saintanim=$"."
var topPos:Vector2
var bottomPos:Vector2
var shouldWobble:bool=false
var isTweening:bool=false
var currentProgress:float=0
@export var timeToMove:float=1
var progressTimer:float=0
var goingBack:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	topPos=position
	bottomPos=position+Vector2(0,5)

	SetShouldWobble(true)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	

	
	var progress=progressTimer/timeToMove
	var pos = lerp(bottomPos,topPos,progress)
	self.position=pos
	
	currentProgress+=delta
	
	pass

func SetShouldWobble(wobble:bool):
	shouldWobble=wobble

	


	
