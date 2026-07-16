extends Base_Enemy

enum States{WALK,WAIT,FALL,SLEEPING}
var state:States=States.WALK
var direction:float=1
const SPEED = 40.0

@export var timeInWait=1
@export var timeBeforeTurning:float=0.2
var turningCounter:float=0
var waitCounter=0
var speed:Vector2=Vector2(0,0)
var cuteSleeper:bool=false
var goingToSleep:bool=false
var sleeping:bool=false
@export var showdebuglabel:bool
@onready var debuglabel=$Label


func _ready() -> void:
	
	GlobalVariables.birdyIsSleeping.connect(BirdySleep)
	
	if showdebuglabel:
		debuglabel.show()
	else:
		debuglabel.hide()

func BirdySleep(_sleeping:bool):
	if _sleeping and !sleeping:
		GoToSleep()
	elif !sleeping:
		WakeUp()	


	pass

func _physics_process(delta: float) -> void:
	
	if showdebuglabel:
		if Input.is_action_just_pressed("sing"):
			if sleeping:
				WakeUp()
			else:	
				GoToSleep()
	
	if enemyInfo.dead or gamePaused:
		return
	
	CheckIfSleeping(delta)
	if enemySleep:
		return	

	dontGoToSleep=false

	if not is_on_floor():
		velocity += -get_gravity() * delta * 0.3
		

	if !is_on_ceiling():
		dontGoToSleep=true

	var _anim=anim.animation



	if state==States.WALK:
		if showdebuglabel: 
			debuglabel.text="walking"
		_anim="run"
		
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
		if showdebuglabel: debuglabel.text="wait"
		_anim="idle"
		velocity.x=0
		waitCounter+=delta
		if waitCounter>timeInWait:
			waitCounter=0
			state=States.WALK
			
	if state==States.SLEEPING:
		if showdebuglabel: debuglabel.text="sleeping"
		
		velocity.x=0
		if sleeping:	
			_anim=UpdateSleepAnim()

	#Done at the end of upate, used in the next loop
	
	if GetIsFalling():
		if !isFalling:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_GENERIC_FALL)
		isFalling=true
	else:
		isFalling=false
	
	if isFalling:
		debuglabel.text="falling"
		_anim="fall"
		
		velocity.x=0
	


	positionLastFrame=position
	move_and_slide()
	UpdateAnimations(_anim)

func DealDamage(value:int,spawnCorpse:bool=true): #MUST HAVE
	if value>0:
		Kill(true,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_CLOUD_DEATH,spawnCorpse)
		#TODO: Fancy kill animation

func GoToSleep():
	return
	state=States.SLEEPING
	goingToSleep=true

	var waitTime = randf()
	
	await get_tree().create_timer(waitTime).timeout

	var rand=(randf())
	if rand>0.8:
		cuteSleeper=true
		
	if goingToSleep:
		anim.play("goingtosleep")
		await anim.animation_finished
	
	waitTime = randf()*0.5
	
	await get_tree().create_timer(waitTime).timeout
	
	if goingToSleep:
		#we can set goingtosleep to false to ignore the timer if cloud wakes up fast
		if goingToSleep:
			goingToSleep=false
			sleeping=true


func UpdateSleepAnim():
	var an:String
	if cuteSleeper:
		an="sleeping_cute"
	else:
		an="sleeping"
		
	return an

func WakeUp():
	state=States.WAIT
	waitCounter=0
	sleeping=false
	goingToSleep=false


func UpdateAnimations(_anim:String):

	if _anim != anim.animation: 
		anim.animation=_anim
		anim.play(_anim)
		anim.flip_h=direction <0

	pass
