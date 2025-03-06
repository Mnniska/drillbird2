extends Node2D
class_name star_fragment

@export var worth:float=20
@export var speedMax:float=100
@export var speedMin=50
var speed=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed=randf_range(speedMax,speedMin)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position.x-=speed*delta
	
	pass
