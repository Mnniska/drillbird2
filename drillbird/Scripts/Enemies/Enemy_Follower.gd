extends Base_Enemy
class_name enemy_follower

const MAX_SPEED = 200
const JUMP_VELOCITY = -400.0
var direction:float=1
@onready var collider=$EnemyCollisionChecker
var visibleActors:Array[Node2D]
var chosenActor:Node2D

const BUFFER_ZONE:int=2
const PREDICTION_LENGTH:int=6
var chosenActorXCoordinateLastFrame:float=0
var dir=0

@onready var timer:Timer=$LoseDetectionTimer


enum States{IDLE,ALERT}
var state:States = States.IDLE

func GetCollType(): #MUST HAVE
	return collType

func SetGamePaused(paused:bool):
	gamePaused=paused

func _ready() -> void:
	enemyInfo=enemyInfo.duplicate()

	if enemyInfo.dead:
		TurnEnemyOff()
	
	GlobalVariables.signal_IsPlayerInMenuChanged.connect(SetGamePaused)
	spawnPositionLocal=position #MUST HAVE
	
func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead or gamePaused:
		return
		
	CheckIfSleeping(delta)
	if enemySleep:
		return
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	
	if state==States.IDLE:
		IdleBehaviour()
	if state==States.ALERT:
		AlertBehaviour()

	
	move_and_slide()
	UpdateAnimations("butt")
	

	
	
	pass
	
func IdleBehaviour():
	velocity.x=0
	move_and_slide()
	pass

func AlertBehaviour():
	

	
	var velocityVector:float = chosenActorXCoordinateLastFrame-chosenActor.global_position.x
	

	if velocityVector>0:
		dir=-1
	else:
		if velocityVector<0:
			dir=1
	
	#Not used - TODO figure this out lol
	var multiplier: float=   abs(chosenActor.global_position.x-global_position.x) / PREDICTION_LENGTH
	
	var target = chosenActor.global_position.x+PREDICTION_LENGTH*dir

	#dist 0 = 0
	#dist BUFFER = 1
	
	
	var diff = global_position.x-target


	velocity.x=-diff*7

	
	if abs(global_position.x-target) <=BUFFER_ZONE:
		velocity.x=0
	
	
	chosenActorXCoordinateLastFrame=chosenActor.global_position.x
	
	
func GetLocalSpawnPosition(): #MUST HAVE
	return spawnPositionLocal
	
func Setup(info:abstract_enemy): #MUST HAVE
	enemyInfo.spawnLocation=info.spawnLocation
	enemyInfo.dead=info.dead

func DealDamage(value:int): #MUST HAVE
	if value>0:
		Kill()
		#TODO: Fancy kill animation



func TurnEnemyOff(hideInstantly:bool=true):
	if hideInstantly:
		hide()
	$CollisionShape2D.set_deferred("disabled",true)
	$EnemyCollisionChecker.set_deferred("disabled",true)
	$EnemyCollisionChecker.set_deferred("monitoring",false)

	velocity=Vector2(0,0)
	timer.stop()
	
	
func Kill():
	enemyInfo.dead=true
	TurnEnemyOff()
	



func UpdateAnimations(_anim:String):

	var anim:String=""
	match state:
		States.IDLE:
			anim="idle"
			pass
		States.ALERT:
			anim="alert"
			if abs(velocity.x)>0:
				anim="run"
			pass
			
	$AnimatedSprite2D.animation = anim
	$AnimatedSprite2D.flip_h=velocity.x < 0

	pass # Replace with function body.

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



func _on_vision_field_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==self:
		return
	
	visibleActors.append(body)
	
	if visibleActors.size()>0:
		var Olddist:float=10000
		for n in visibleActors:
			var distance= min(Olddist,abs(global_position.y-n.global_position.y))
		
			if distance<Olddist:
				Olddist=distance
				chosenActor=n
	
	timer.stop()

	
	if state==States.IDLE:
		state=States.ALERT
	
	pass # Replace with function body.


func _on_vision_field_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	var index=0
	for n in visibleActors:
		if n==body:
			visibleActors.remove_at(index )
		index+=1

	if visibleActors.size()>0:
		var dist:float=100
		for n in visibleActors:
			var distance= min(dist,abs(global_position.y-n.global_position.y))
		
			if distance<dist:
				dist=distance
				chosenActor=n
		
	else:
		timer.start()


func _on_lose_detection_timer_timeout() -> void:
	chosenActor=null
	state=States.IDLE
	#todo: move towards the center of a tile
	
	pass # Replace with function body.
