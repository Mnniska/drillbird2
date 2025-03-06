extends CharacterBody2D
class_name flying_child 

@onready var animator=$Animator
@onready var slider:HSlider = %UI_LightSlider

@export var gravity:float=2
@export var speedAtWhichFallingAnimTriggers:float=50
@export var jumpHeight:float=150
@export var heldJumpSpeed:float=20
@export var moveSpeed:float=15
@export var maxHorizontalSpeed:float=80
@export var maxVerticalSpeed:float=80
@export var friction:float=2

@export var maxEnergy:float=100
var energy:float=20
@export var initialJumpCost:float=10
@export var continuedJumpCost:float=2


enum States{IDLE,JUMPING,FALLING,INACTIVE,GROWN}
var state:States=States.INACTIVE


@export var maxFuelRefillRate:float=5
@export var maxJumpTime=0.6
var energyRefillRatePerSecond:float=maxFuelRefillRate


var jumpTime:float=0.6
var jumpTimeCounter:float=0

var lastAnimatedState:States
var holdTime:float=0
var simulatedJumpPressed:bool=false

var shake:bool=false
@onready var evolveShine=$anim_evolve_shine



func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_tab"):
		GrowUp()
	
	if state==States.INACTIVE:
		return
	
	if state==States.GROWN:
		GrownUpdate(delta)
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


	if state!=States.JUMPING:
		RefillEnergyBar(delta)
	UpdateEnergyBar()
	UpdateAnimations()
	move_and_slide()

func GrownUpdate(delta:float):
	
	if shake:
		var variance=2
		var rand=randf_range(-variance,variance)
		animator.position=Vector2(rand,0)
	
	velocity.y+=gravity*delta*1.5
	UpdateAnimations()
	move_and_slide()

func RefillEnergyBar(delta:float):
	
	var multiplier=delta/1
	var gain =energyRefillRatePerSecond*multiplier
	
	var mult=1
	if energy>50:
		mult=0.5
	
	energy=min(maxEnergy,energy+gain*mult)
	

func UpdateEnergyBar():
	if slider:
		slider.value=energy
	
	pass

func GrowUp():
	velocity.y=0
	velocity.x=clampf(velocity.x,-2,2)
	state=States.GROWN
	animator.animation="growup"
	animator.play()
	shake=true
	await get_tree().create_timer(1).timeout
	shake=false
	evolveShine.play()
	
	
	pass
func _on_animator_animation_finished() -> void:
	pass # Replace with function body.

func initiateJump(_holdtime:float):
	
	if state==States.JUMPING or state==States.GROWN:
		return
	
	state=States.JUMPING
	energy-=initialJumpCost

	if _holdtime>0:
		simulatedJumpPressed=true
		holdTime=_holdtime
	velocity.y=-jumpHeight
	animator.animation="up"
	animator.play()
	pass
	
func continueJump(delta:float):
	energy-continuedJumpCost
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


func _on_star_fragment_checker_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	
	var starfragment:star_fragment=area.get_parent()
	energy+=starfragment.worth
	starfragment.queue_free()
	
	pass # Replace with function body.
