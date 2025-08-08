extends Node2D
class_name option_scroller

var originalPos:Vector2
@export var distance=18

func _ready() -> void:
	originalPos=self.position

func NewTarget(numberInList:int=0):

	position=originalPos - Vector2(0,numberInList*distance)

	pass
