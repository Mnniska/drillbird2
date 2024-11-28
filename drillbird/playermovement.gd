extends CharacterBody2D

var animstate=""
enum Directions {LEFT, RIGHT, UP, DOWN}
var facingDir= Directions.RIGHT
@export var SPEED = 100.0
@export var JUMP_VELOCITY = -200.0


func _ready() -> void:
	Update_Animations("idle")

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	var newanim=animstate
	if direction:
		velocity.x = direction * SPEED
		
		if velocity.x > 0:
			facingDir=Directions.RIGHT
		elif velocity.x<0:
			facingDir=Directions.LEFT
		newanim="run"
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		newanim="idle"
		
		#if not moving left/right, handle whether char should look up/down
		
		if Input.is_action_pressed("up"):
			facingDir=Directions.UP
			newanim="idle_up"
		if Input.is_action_pressed("down"):
			facingDir=Directions.DOWN
			newanim="idle_down"
			
		if Input.is_action_pressed ("drill"):
			newanim="drill_side"

	move_and_slide()
	Update_Animations(newanim)
	
func Update_Animations(newanim):
	
	if facingDir == Directions.LEFT:
		$AnimatedSprite2D.flip_h=true
	if facingDir == Directions.RIGHT:
		$AnimatedSprite2D.flip_h=false
	
	if newanim !=animstate:
		animstate=newanim
		$AnimatedSprite2D.animation=animstate

	
