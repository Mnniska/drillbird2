extends PanelContainer

@onready var background=$placement_node/BoxContainer/PanelContainer

@export var tex_bg_off:Texture
@export var tex_bg_active:Texture



func SetSelected(selected:bool): 
	
	var tex=tex_bg_off
	if selected:
		tex=tex_bg_active
	
	var styleBox: StyleBoxTexture = background.get_theme_stylebox("panel").duplicate()
	styleBox.set("texture", tex)
	background.add_theme_stylebox_override("panel", styleBox)
	
func isButton():
	return true

func AttemptToPurchase():
	return false
