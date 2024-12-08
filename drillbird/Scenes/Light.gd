extends Node2D

@export var lightTexture:GradientTexture2D
@onready var lightSource=$light_full
@export var minLight:float =0.15
@export var maxLight:float = 0.9

var test:float =maxLight
var dir:bool=false

#0=complete darkness. 1=completely lit
var lightStrength:float=1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass

func SetLight(lightstr):
	
	var test =clamp(lightstr,minLight,maxLight)
	
	var a :float = maxLight*lightstr+minLight*(1-lightstr)
	
	var gradient_data := {
	
	1: Color.WHITE,
	a: Color.WHITE,
	0.1: Color.BLACK,
	0: Color.BLACK,

	}
	var gradient := Gradient.new()
	gradient.offsets = gradient_data.keys()
	gradient.colors = gradient_data.values()
	lightTexture.gradient = gradient
	
	lightSource.texture=lightTexture
	
	pass
