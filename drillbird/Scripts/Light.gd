extends Node2D

@export var lightTexture:GradientTexture2D
@export var lightSource:PointLight2D
@export var minLight:float =0.1
@export var maxLight:float = 0.9
@onready var playerAvatar= $"../Player"
@onready var Camera=$"../Camera2D"
var isFollowingPlayer:bool=true
var dir:bool=false

#0=complete darkness. 1=completely lit
var lightStrength:float=1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GlobalVariables.playerStatusChanged.connect(playerStateChanged)
	SetLight(maxLight)
	pass # Replace with function body.

func playerStateChanged():
	if GlobalVariables.playerStatus!=GlobalVariables.playerStatusEnum.DIG:
		isFollowingPlayer=false
	
	if GlobalVariables.playerStatus==GlobalVariables.playerStatusEnum.DIG:
		isFollowingPlayer=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if isFollowingPlayer:
		self.position=playerAvatar.position
	else:
		self.position=Camera.position
	pass

func SetLight(lightstr):
	
	var test =clamp(lightstr,minLight,maxLight)
	
	var a :float = maxLight*lightstr+minLight*(1-lightstr)
	var b = clampf(a-0.3,0,a)
	
	var gradient_data := {
	1: Color.BLACK,
	a: Color.BLACK,
	b: Color.WHITE,
	0.0: Color.WHITE,
	}
	
	var gradient := Gradient.new()
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()
	lightTexture.gradient = gradient
	
	lightSource.texture=lightTexture
	
	pass
