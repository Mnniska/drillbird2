extends Node2D

@export var defaultNum:int 
@export var numtextures:Array[Texture2D]
@onready var number:Sprite2D = $number

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	setNumber(defaultNum)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setNumber(num:int):
	if(num>-1&&num<10):
		number.texture=numtextures[num]
		show()
	elif(num==-1):
		hide()
	else:
		push_warning("attempted to set a number outside of range")
	pass
