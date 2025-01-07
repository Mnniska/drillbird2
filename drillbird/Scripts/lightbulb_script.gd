extends Sprite2D
@export var tex_active :Texture2D
@export var tex_off :Texture2D
var active:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func SetActive(_active:bool):
	active=_active
	if(active):
		texture = tex_active
	else:
		texture = tex_off

func SetDebugText(str:String):
	$Label.text=str
