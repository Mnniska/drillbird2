extends CharacterBody2D

@export var collType:abstract_collidable #MUST HAVE
@export var enemyInfo:abstract_enemy #MUST HAVE
@onready var anim=$AnimatedSprite2D
const SPEED = 40.0
const JUMP_VELOCITY = -400.0
var direction:float=1
var positionLastFrame:Vector2
@export var timeInWait=1
var waitCounter=0

var spawnPositionLocal:Vector2
@onready var collider=$EnemyCollisionChecker

enum States{WALK,WAIT}
var state:States=States.WALK

func GetCollType(): #MUST HAVE
	return collType

func _ready() -> void:
	enemyInfo=enemyInfo.duplicate()
	
	if enemyInfo.dead:
		TurnEnemyOff()
	
	spawnPositionLocal=position #MUST HAVE
	positionLastFrame=position
	
func GetLocalSpawnPosition(): #MUST HAVE
	return spawnPositionLocal
	
func Setup(info:abstract_enemy): #MUST HAVE
	enemyInfo.spawnLocation=info.spawnLocation
	enemyInfo.dead=info.dead

func DealDamage(value:int): #MUST HAVE
	if value>0:
		Kill()
		#TODO: Fancy kill animation



func TurnEnemyOff():
	hide()
	$CollisionShape2D.set_deferred("disabled",true)
	$EnemyCollisionChecker.set_deferred("disabled",true)
	$EnemyCollisionChecker.set_deferred("monitoring",false)

	velocity=Vector2(0,0)
	
	
func Kill():
	enemyInfo.dead=true
	TurnEnemyOff()
	


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
	
	if enemyInfo.dead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if state==States.WALK:
		
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)



	move_and_slide()
	UpdateAnimations()

	if state==States.WALK:
		
		var speed = positionLastFrame-position
		if speed.x==0:

			direction=direction*-1
			state=States.WAIT
		positionLastFrame=position
	

	if state==States.WAIT:
		waitCounter+=delta
		if waitCounter>timeInWait:
			waitCounter=0
			state=States.WALK

func UpdateAnimations():

	if state==States.WAIT:
		anim.animation="idle"
	if state==States.WALK:
		anim.animation="run"
		
	anim.flip_h=direction <0
