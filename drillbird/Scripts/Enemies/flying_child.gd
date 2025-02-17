extends CharacterBody2D

@onready var animator=$Animator

@export var gravity:float=2
@export var speedAtWhichFallingAnimTriggers:float=50
@export var jumpHeight:float=150
@export var heldJumpSpeed:float=20
@export var moveSpeed:float=15
@export var maxHorizontalSpeed:float=80
@export var maxVerticalSpeed:float=80
@export var friction:float=2

enum States{IDLE,JUMPING,FALLING}
var state:States=States.IDLE

var jumpTime:float=0.6
var jumpTimeCounter:float=0

var lastAnimatedState:States


func _physics_process(delta: float) -> void:
	
	velocity.x=move_toward(velocity.x,0,friction)
	if Input.is_action_pressed("left"):
		velocity.x-=moveSpeed

	if Input.is_action_pressed("right"):
		velocity.x+=moveSpeed
	
	velocity.x=min(maxHorizontalSpeed,velocity.x)
	velocity.x=max(-maxHorizontalSpeed,velocity.x)
	velocity.y=clampf(velocity.y,-maxVerticalSpeed,maxVerticalSpeed)
	
	if Input.is_action_just_pressed("jump"):
		if state!=States.JUMPING:
			initiateJump()
	
	if Input.is_action_pressed("jump") and state==States.JUMPING:
		continueJump(delta)
	elif state==States.JUMPING:
		StopJump()
	
	velocity.y+=gravity
	if state!=States.JUMPING:
		if velocity.y > speedAtWhichFallingAnimTriggers:
			state=States.FALLING
		else:
			state=States.IDLE
	
	UpdateAnimations()
	move_and_slide()
	
func _on_animator_animation_finished() -> void:
	pass # Replace with function body.

func initiateJump():
	state=States.JUMPING
	velocity.y=-jumpHeight
	animator.animation="up"
	pass

func UpdateAnimations():
	
	#Ensures animations only update once when a state changes
	if lastAnimatedState!=state:
		
		match state:
			States.IDLE:
				animator.animation="idle"
			States.JUMPING:
				animator.animation="up"
			States.FALLING:
				animator.animation="down"
	
		lastAnimatedState=state


func continueJump(delta:float):
	velocity.y-=heldJumpSpeed
	jumpTimeCounter+=delta
	if jumpTimeCounter>=jumpTime:
		StopJump()

	pass

func StopJump():
	jumpTimeCounter=0
	state=States.IDLE
	pass
