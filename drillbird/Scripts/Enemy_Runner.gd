extends CharacterBody2D

@export var collType:abstract_collidable
@export var enemyInfo:abstract_enemy
const SPEED = 50.0
const JUMP_VELOCITY = -400.0
var direction:float=1
var spawnPositionLocal:Vector2

func _ready() -> void:
	if enemyInfo.dead:
		TurnEnemyOff()
	else:
		StartMoving()
	spawnPositionLocal=position
	
func GetLocalSpawnPosition():
	return spawnPositionLocal
	
func Setup(info:abstract_enemy):
	enemyInfo=abstract_enemy.new()
	enemyInfo.spawnLocation=info.spawnLocation
	enemyInfo.dead=info.dead
	enemyInfo.type=info.type

func TurnEnemyOff():
	hide()
	$CollisionShape2D.set_deferred("disabled",true)
	velocity=Vector2(0,0)
	$Timer.stop()
	
	
func Kill():
	enemyInfo.dead=true
	TurnEnemyOff()
	
func StartMoving():
	$Timer.start()



func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func UpdateAnimations():

	$AnimatedSprite2D.flip_h=direction <0

func GetCollType():
	return collType
	

func _on_timer_timeout() -> void:
	
	direction=direction*-1
	UpdateAnimations()
	
	pass # Replace with function body.
