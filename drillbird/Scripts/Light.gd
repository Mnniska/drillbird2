extends Node2D

@export var lightTexture:GradientTexture2D
@onready var lightSource=$light_full
@export var minLight:float =0.1
@export var maxLight:float = 0.9
@onready var playerAvatar= $"../Player"

var dir:bool=false

#0=complete darkness. 1=completely lit
var lightStrength:float=1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetLight(maxLight)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.position=playerAvatar.position
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