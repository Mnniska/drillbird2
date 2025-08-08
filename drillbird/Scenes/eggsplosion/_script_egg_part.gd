extends RigidBody2D
class_name eggpart

@export var egg_variants:Array[Texture2D]
@onready var sprite=$eggpart

func _ready() -> void:
	
	sprite.texture=egg_variants[randi_range(0,egg_variants.size()-1)]
