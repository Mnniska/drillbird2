extends Base_Enemy

enum States{WALK,WAIT,FALL}
var state:States=States.WALK
var direction:float=1
const SPEED = 40.0

@export var timeInWait=1
@export var timeBeforeTurning:float=0.2
var turningCounter:float=0
var waitCounter=0
var speed:Vector2=Vector2(0,0)

func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead or gamePaused:
		return
	
	CheckIfSleeping(delta)
	if enemySleep:
		return	

	if not is_on_floor():
		velocity += -get_gravity() * delta * 0.3


	var anim="run"

	move_and_slide()

	if state==States.WALK:
		anim="run"
		
		velocity.x = direction * SPEED
		
		var diff=abs(positionLastFrame-position)
		if diff.x < 0.1 and !isFalling:
			turningCounter+=delta
			if turningCounter>=timeBeforeTurning:
				turningCounter=0
				direction=direction*-1
				state=States.WAIT
		elif turningCounter>0:
			turningCounter=0
			


	if state==States.WAIT:
		anim="idle"
		waitCounter+=delta
		if waitCounter>timeInWait:
			waitCounter=0
			state=States.WALK

	#Done at the end of upate, used in the next loop
	
	if GetIsFalling():
		if !isFalling:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_GENERIC_FALL)
		isFalling=true
	else:
		isFalling=false
	
	if isFalling:
		anim="fall"
	
	
	positionLastFrame=position
	UpdateAnimations(anim)

func DealDamage(value:int): #MUST HAVE
	if value>0:
		Kill(abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_CLOUD_DEATH)
		#TODO: Fancy kill animation

func UpdateAnimations(_anim:String):


	
	anim.animation=_anim
	anim.flip_h=direction <0

	pass
