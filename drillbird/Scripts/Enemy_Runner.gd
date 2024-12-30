extends CharacterBody2D

@export var collType:abstract_collidable
const SPEED = 50.0
const JUMP_VELOCITY = -400.0
var direction:float=1
var spawnPosition:Vector2

func _ready() -> void:
	StartMoving()
	spawnPosition=position

func StartMoving():
	$Timer.start()

func GetSpawnPosition():
	return spawnPosition

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func UpdateAnimations():

	$AnimatedSprite2D.flip_h=direction <0

func GetCollType():
	return collType
	

func _on_timer_timeout() -> void:
	
	direction=direction*-1
	UpdateAnimations()
	
	pass # Replace with function body.
