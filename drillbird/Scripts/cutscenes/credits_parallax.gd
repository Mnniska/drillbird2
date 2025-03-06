extends Sprite2D
@export var speedModifier:float=1:
	get:return speedModifier
	set(value):
		speedModifier=value
		UpdateParallax(speedModifier*baseSpeed)
@export var baseSpeed=50

var showParallax:bool=true
@export var timeToFadeTimer:float=2
var fadeCounter:float=timeToFadeTimer

func _ready() -> void:
	UpdateParallax (baseSpeed*speedModifier)

func _process(delta: float) -> void:
	
	if !showParallax and fadeCounter > 0:
		fadeCounter = max(0,fadeCounter-delta)
		UpdateFade(fadeCounter/timeToFadeTimer)
	
	if showParallax and fadeCounter < timeToFadeTimer:
		fadeCounter = min(timeToFadeTimer,delta+fadeCounter)
		UpdateFade(fadeCounter/timeToFadeTimer)

func UpdateFade(amount:float):
	var col:Color=Color(Color.WHITE,amount)
	modulate=col

func UpdateParallax(speed):
	material.set_shader_parameter("motion",Vector2(speed,0))
