extends RigidBody2D
class_name eggpart

@export var egg_variants:Array[Texture2D]
@onready var sprite:Sprite2D=$eggpart

@export var minDespawnTime:float=1
@export var maxDespawnTime:float=5

var initialLifetime:float
var timeToFade:float=1
var timer:float=0
var isFading:bool=false
var alpha=1	

func _ready() -> void:
	sprite.texture=egg_variants[randi_range(0,egg_variants.size()-1)]
	initialLifetime=randf_range(minDespawnTime,maxDespawnTime)
	
func _process(delta: float) -> void:
	timer+=delta
	
	if timer>initialLifetime:
		isFading=true
	
	if isFading:
		alpha-=delta*2
		sprite.self_modulate=Color(sprite.modulate,alpha)
		
		if alpha<=0:
			queue_free()
	

func SetColor(col:Color):
	sprite.modulate=col
	pass
