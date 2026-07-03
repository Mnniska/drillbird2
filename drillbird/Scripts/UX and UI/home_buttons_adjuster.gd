extends Node2D
@export var maximumHeightDifference:float=30
var originalYLocation:float


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	originalYLocation=position.y
	pass # Replace with function body.

func UpdateButtonPosition(progress:float):
	var yPos=originalYLocation-maximumHeightDifference*progress
	
	position=Vector2(position.x,yPos)
