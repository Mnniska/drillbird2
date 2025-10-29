extends RigidBody2D
class_name eggpart

@export var egg_variants:Array[Texture2D]
@onready var sprite=$eggpart

@export var minDespawnTime=1
@export var maxDespawnTime=5

func _ready() -> void:
	
	sprite.texture=egg_variants[randi_range(0,egg_variants.size()-1)]
	await get_tree().create_timer(randf_range(minDespawnTime,maxDespawnTime)).timeout
	queue_free()
