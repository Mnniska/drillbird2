extends Node2D
var selected:bool=false
@export var texture_selected:Texture
@export var texture_inactive:Texture
@export var texture_pressed:Texture
@onready var buttonFrame=$buttonFrame
@onready var text = $text

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func isButton():
	return true
	
func SetSelected(_selected:bool):
	selected=_selected
	var tex:Texture
	if selected:	
		tex=texture_selected
	else:
		tex=texture_inactive
		
	buttonFrame.texture=tex
	
