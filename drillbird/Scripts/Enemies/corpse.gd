extends CharacterBody2D

var positionLastFrame
var isFalling:bool=true
@onready var animator=$AnimatedSprite2D
@export var collType:abstract_collidable
@export var enemyInfo:abstract_enemy

var hasLanded:bool=false

enum fallEnum{up,neutral,down}
var fallState:fallEnum

func _ready() -> void:
	positionLastFrame=position

func _physics_process(delta: float) -> void:
	var anim="idle"
		# Add the gravity.
	if is_on_floor():
		anim="land"
	else:
		velocity += get_gravity() * delta*0.5
		anim=GetIsFalling()
	
		
	positionLastFrame=position #must be called before move_and_slide but after functions that need it
	UpdateAnimations(anim)
	move_and_slide()

func UpdateAnimations(anim:String):
	if anim!=animator.animation:
		animator.play(anim)

func GetIsFalling()->String:
	#Make sure to update PositionLastFrame AFTER this
	var speed = abs(positionLastFrame-position)
	
	if speed.y>0.1:
		return "fall_down"
	
	if speed.y<-0.1:
		return "fall_up"
	
	return "fall_neutral"


func DealDamage(amount:int=1):
	if amount>0:
		DestroySelf()
#Should only be called from tombstone script 
	
func DestroySelf():
	queue_free()
	pass

func GetCollType():
	return collType
