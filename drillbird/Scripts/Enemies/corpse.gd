extends CharacterBody2D

var positionLastFrame
var isFalling:bool=true
@onready var animator=$AnimatedSprite2D
@export var collType:abstract_collidable
@export var enemyInfo:abstract_enemy

func _ready() -> void:
	positionLastFrame=position

func _physics_process(delta: float) -> void:
	
		# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta*0.5


	var anim="falling"
	isFalling = GetIsFalling()
	if !isFalling:
		anim="idle"
		
	positionLastFrame=position #must be called before move_and_slide but after functions that need it
	UpdateAnimations(anim)
	move_and_slide()

func UpdateAnimations(anim:String):
	if anim!=animator.animation:
		animator.play(anim)

func GetIsFalling():
	#Make sure to update PositionLastFrame AFTER this
	var speed = abs(positionLastFrame-position)
	
	return speed.y>0.1

func DealDamage(amount:int=1):
	if amount>0:
		DestroySelf()
#Should only be called from tombstone script 
	
func DestroySelf():
	queue_free()
	pass

func GetCollType():
	return collType
