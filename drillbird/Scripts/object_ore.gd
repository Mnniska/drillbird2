extends RigidBody2D
@onready var anim: AnimatedSprite2D =$Animation
@export var ObjectInfo:abstract_collidable
@export var oreType:abstract_ore
@onready var oreSprite:Sprite2D = $oreSprite
var cooldown:bool=false
var cooldownTime:float=2
var MoveTarget:Vector2
var isBeingSuckedUp:bool=false

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
	

func MoveTowardsHome(pos:Vector2):
	MoveTarget=pos
	isBeingSuckedUp=true
	gravity_scale=0.5
	
	while linear_velocity.x>0:
		linear_velocity.x=move_toward(linear_velocity.x,0,0.2)
		linear_velocity.y=move_toward(linear_velocity.y,0,1)
		await get_tree().create_timer(randf_range(0.1,0.2)).timeout

		pass
	
	while isBeingSuckedUp:
		var pointVector = MoveTarget-self.position
		pointVector=pointVector.normalized()
		
		var force=200
		apply_central_impulse(Vector2(pointVector.x*force,0))
		
		await get_tree().create_timer(randf_range(0.2,0.5)).timeout
	
	pass

func _on_animation_animation_finished() -> void:
	anim.animation="idle"
	pass # Replace with function body.
