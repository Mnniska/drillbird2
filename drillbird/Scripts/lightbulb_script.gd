extends HSlider
class_name light_bulb
@onready var slider:HSlider=$"."
var hasLight:bool=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func SetSliderProgress(_prog:float):
	slider.value=roundi(_prog*100)
	hasLight=_prog>0.1
