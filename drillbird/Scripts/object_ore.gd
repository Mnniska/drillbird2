extends RigidBody2D
@onready var anim: AnimatedSprite2D =$Animation
@export var ObjectInfo:abstract_collidable
@export var oreType:abstract_ore
@onready var oreSprite:Sprite2D = $oreSprite

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func GetCollType():
	
	
	return ObjectInfo

func GetOre():
	if abstract_ore:
		return abstract_ore
	else:
		push_warning("Tried to access a null oretype")

func SetOreType(ore:abstract_ore):
	if(oreType==null):
		oreType=ore
		oreSprite.texture=oreType.texture
	pass

func _on_animation_animation_finished() -> void:
	anim.animation="idle"
	pass # Replace with function body.
