extends Base_Enemy

enum States{WALK,WAIT}
var state:States=States.WALK
var direction:float=1
const SPEED = 40.0
var positionLastFrame:Vector2

@export var timeInWait=1
@export var timeBeforeTurning:float=0.2
var turningCounter:float=0
var waitCounter=0

func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead or gamePaused:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += -get_gravity() * delta

	if state==States.WALK:
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	var anim="idle"
	
	if state==States.WALK:
		anim="run"


	move_and_slide()
	UpdateAnimations(anim)

	if state==States.WALK:
		
		var speed = abs(positionLastFrame-position)
		if speed.x<=0.1:
			turningCounter+=delta
			if turningCounter>=timeBeforeTurning:
				turningCounter=0
				direction=direction*-1
				state=States.WAIT
		elif turningCounter>0:
			turningCounter=0
			
		positionLastFrame=position


	if state==States.WAIT:
		waitCounter+=delta
		if waitCounter>timeInWait:
			waitCounter=0
			state=States.WALK
func UpdateAnimations(_anim:String):

	anim.animation=_anim
	anim.flip_h=direction <0

	pass
