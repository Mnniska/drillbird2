extends Base_Enemy

const SPEED = 40.0
const JUMP_VELOCITY = -400.0
var direction:float=1
@export var timeInWait=1
var waitCounter=0
var turningCounter=0
var timeBeforeTurning=0.2

@onready var collider=$EnemyCollisionChecker

enum States{WALK,WAIT}
var state:States=States.WALK

func GetCollType(): #MUST HAVE
	return collType

func _ready() -> void:
	
	if enemyInfo.dead:
		TurnEnemyOff()
	
	spawnPositionLocal=position #MUST HAVE
	positionLastFrame=position

func SetGamePaused(paused:bool):
	gamePaused=paused

func GetLocalSpawnPosition(): #MUST HAVE
	return spawnPositionLocal
	

func DealDamage(value:int): #MUST HAVE
	if value>0:
		Kill(true,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_WALKER_DEATH)



func TurnEnemyOff(hideInstantly:bool=true):
	if hideInstantly:
		hide()
	$CollisionShape2D.set_deferred("disabled",true)
	$EnemyCollisionChecker.set_deferred("disabled",true)
	$EnemyCollisionChecker.set_deferred("monitoring",false)

	velocity=Vector2(0,0)
	


func CheckOverlappingCollisions(): #MUST HAVE
	for n in collider.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(enemyInfo.damage)
	pass

func _on_enemy_collision_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead or gamePaused:
		return
		
	CheckIfSleeping(delta)
	if enemySleep:
		return
	var anim="idle"

	

	if state==States.WALK:
		
		if direction:
			velocity.x = direction * SPEED
			anim="run"
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			anim="idle"
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.5
	


	move_and_slide()

	if GetIsFalling():
		if !isFalling:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_GENERIC_FALL)
		isFalling=true
		anim="fall"
	else:
		isFalling=false

	UpdateAnimations(anim)


	if state==States.WALK:
		

		var speed = abs(positionLastFrame-position)
		if speed.x<=0.1 and !isFalling:
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
