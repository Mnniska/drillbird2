extends Base_Enemy
class_name Enemy_Mole

const SPEED = 3000
var mySpeed=SPEED
const JUMP_VELOCITY = -400.0
var direction:float=1
@export var timeInWait=1
var waitCounter=0
var turningCounter=0
var timeBeforeTurning=0.08

@onready var collider=$EnemyCollisionChecker
@onready var diggingRaycast=$DiggingRaycast
@onready var crackAnim=$crack
var TileDestroyer:crack_script=null
@export var timeStunned:float=3
var stunTimer:float=0

enum States{WALK,WAIT,CORPSE,DETECT,DIG,FALLING,DAZED}
var state:States=States.WALK

func GetCollType(): #MUST HAVE
	return collType

func GetTileDestroyer()->crack_script:
	if TileDestroyer==null:
		TileDestroyer=GlobalVariables.MainSceneReferenceConnector.ref_tileDestroyer
	
	return TileDestroyer

func _ready() -> void:
	
	if enemyInfo.dead:
		TurnEnemyOff()
	
	spawnPositionLocal=position #MUST HAVE
	positionLastFrame=position
	mySpeed=GetSpeed()

func GetSpeed()->int:

	return SPEED

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

func _on_enemy_collision_checker_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)
	pass # Replace with function body.

func _physics_process(delta: float) -> void:
	
	if gamePaused:
		return
		
	if enemyInfo.dead:
		return
	
	CheckIfSleeping(delta)
	if enemySleep:
		return
	var _anim=anim.animation

	match state:
		
		States.CORPSE:
			_anim="corpse"
	
		States.DETECT:
			velocity.x=0
			#todo: lerp X towards nearest tile center
			
			pass
			
		States.WALK:
			velocity.x=SPEED*delta*direction*-1
		
			pass
		States.DIG:
			_anim="digging"
			
			pass
		States.FALLING:
			_anim="dazed"
			if GetIsFalling():
				stunTimer=0
			else:
				stunTimer+=delta
				if stunTimer>timeStunned:
					stunTimer=0
					ExitDazed()
					_anim="recover"
					#todo: transition
		
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 0.5
	








	if state==States.WALK:
		_anim="run"
		var speed = abs(positionLastFrame-position)
		if speed.x<=0.2 and !isFalling:
			turningCounter+=delta
			if turningCounter>=timeBeforeTurning:
				turningCounter=0
				direction=direction*-1
				state=States.WAIT
		elif turningCounter>0:
			turningCounter=0
	
	if GetIsFalling():
		if !isFalling:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_GENERIC_FALL)
		isFalling=true
		
		if state==States.FALLING:
			_anim="digfall"
			
		else:
			_anim="fall"
			velocity.x=0
	else:
		isFalling=false

	positionLastFrame=position
	

	if state==States.WAIT:
		_anim="idle"
		waitCounter+=delta
		if waitCounter>timeInWait:
			waitCounter=0
			state=States.WALK

	move_and_slide()
	UpdateAnimations(_anim)

func ExitDazed():
	state=States.DAZED
	anim.play("recover")
	var length=get_current_animation_length()
	await get_tree().create_timer(length).timeout
	state=States.WALK

func UpdateAnimations(_anim:String):
	if anim.animation!=_anim:
		anim.animation=_anim
		anim.play(_anim)

	anim.flip_h=direction > 0
	

func DetectPlayer():
	state=States.DETECT
	
	
	anim.animation="detect"
	anim.play()
	var detectAnimLength:float=get_current_animation_length() 
	

	
	await get_tree().create_timer(detectAnimLength).timeout
	
	anim.animation="digging"
	
	anim.play("digging")
	state=States.DIG
	
	var digSuccessfull:bool=false
	
	if diggingRaycast.is_colliding():
	
		var tileset:TileMapLayer = diggingRaycast.get_collider()
		
		if tileset:
			var pos = diggingRaycast.get_collision_point()
			var tilesetPos=tileset.to_local(tileset.local_to_map(pos))

			var tiledata:TileData= tileset.get_cell_tile_data(tilesetPos)
			
			var crackPos=to_local(tileset.map_to_local(tilesetPos))
			var globalPos=to_global(crackPos)
			global_position.x=globalPos.x
			
			#if tile isn't solid..
			if tiledata.terrain!=0:
				
				crackAnim.play("cracking")
				crackAnim.position=crackPos
				
				var timeToDig=1 #todo change thus number depending on tile hardness
			
				var animSpeed=1
				crackAnim.speed_scale=animSpeed

				await get_tree().create_timer(timeToDig).timeout
				GetTileDestroyer().DestroyTileWithGlobalPosition(pos,true,false)
				digSuccessfull=true
				
				crackAnim.play("idle")
				
				state=States.FALLING

	if !digSuccessfull:
		#tile digging was not successful
		#todo: transition to walking?
		await get_tree().create_timer(1).timeout

		state=States.WAIT
		


func _on_player_detection_zone_body_shape_entered() -> void:
	if state==States.WALK or state==States.WAIT and !GetIsFalling():
		DetectPlayer()
	
	pass # Replace with function body.
