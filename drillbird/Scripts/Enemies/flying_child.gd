extends CharacterBody2D
class_name flying_child 

@onready var animator=$Animator

@export var gravity:float=2
@export var speedAtWhichFallingAnimTriggers:float=50
@export var jumpHeight:float=150
@export var heldJumpSpeed:float=20
@export var moveSpeed:float=15
@export var maxHorizontalSpeed:float=80
@export var maxVerticalSpeed:float=80
@export var friction:float=2

enum States{IDLE,JUMPING,FALLING,INACTIVE}
var state:States=States.INACTIVE

var jumpTime:float=0.6
var jumpTimeCounter:float=0

var lastAnimatedState:States

var holdTime:float=0

var simulatedJumpPressed:bool=false


func _physics_process(delta: float) -> void:
	
	if state==States.INACTIVE:
		return
	
	if holdTime>0:
		holdTime-=delta
		if holdTime<=0:
			simulatedJumpPressed=false
	
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
			initiateJump(0)
	
	if state==States.JUMPING:
		if Input.is_action_pressed("jump") or simulatedJumpPressed:
			continueJump(delta)
		else:
			StopJump()
	
	var modifier=1
	if state==States.IDLE:
		modifier=0.5
	
	velocity.y+=gravity*modifier
	
	if state!=States.JUMPING:
		if velocity.y > speedAtWhichFallingAnimTriggers:
			state=States.FALLING
		else:
			state=States.IDLE

	UpdateAnimations()
	move_and_slide()
	
func _on_animator_animation_finished() -> void:
	pass # Replace with function body.

func initiateJump(_holdtime:float):
	if state==States.JUMPING:
		return
		
	state=States.JUMPING

	if _holdtime>0:
		simulatedJumpPressed=true
		holdTime=_holdtime
	velocity.y=-jumpHeight
	animator.animation="up"
	pass
	
func continueJump(delta:float):
	velocity.y-=heldJumpSpeed
	jumpTimeCounter+=delta
	if jumpTimeCounter>=jumpTime:
		StopJump()

	pass

func StopJump():
	jumpTimeCounter=0
	state=States.IDLE
	simulatedJumpPressed=false
	holdTime=0
	pass

func UpdateAnimations():
	
	#Ensures animations only update once when a state changes
	if lastAnimatedState!=state:
		
		match state:
			States.IDLE:
				animator.animation="idle"
				animator.play()
			States.JUMPING:
				animator.animation="up"
			States.FALLING:
				animator.animation="down"
	
		lastAnimatedState=state
