extends RigidBody2D
@onready var anim: AnimatedSprite2D =$Animation
@export var ObjectInfo:abstract_collidable
@export var oreType:abstract_ore
@onready var oreSprite:Sprite2D = $oreSprite
var cooldown:bool=false
var cooldownTime:float=2

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

func SetOreType(ore:abstract_ore,_cooldown:bool):
	if(oreType==null):
		
		oreType=ore
		oreSprite.texture=oreType.texture
		cooldown=_cooldown
		
		if cooldown:
			CooldownAnimation()
	pass

func CooldownAnimation():
	
	var a=1.0
	var b = 0.5
	var time = 0.1
	var timeKeeper=0
	
	while cooldown:
		oreSprite.self_modulate=Color(1,1,1,b)
		await get_tree().create_timer(time).timeout
		oreSprite.self_modulate=Color(1,1,1,a)
		await get_tree().create_timer(time).timeout
		
		timeKeeper+=time*2
		if timeKeeper>cooldownTime:
			cooldown=false
			#TODO: Check if colliding with player once this happens


	pass

func _on_animation_animation_finished() -> void:
	anim.animation="idle"
	pass # Replace with function body.
