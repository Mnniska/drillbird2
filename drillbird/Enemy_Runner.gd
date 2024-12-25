extends CharacterBody2D


const SPEED = 50.0
const JUMP_VELOCITY = -400.0
var direction:float=1

func _ready() -> void:
	StartMoving()

func StartMoving():
	$Timer.start()

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

func _on_timer_timeout() -> void:
	
	direction=direction*-1
	UpdateAnimations()
	
	pass # Replace with function body.
