extends CharacterBody2D
class_name Base_Enemy

@export var collType:abstract_collidable #MUST HAVE
@export var enemyInfo:abstract_enemy #MUST HAVE
var spawnPositionLocal:Vector2
@onready var enemyCollider=$CollisionShape2D
@onready var enemyCollCheck=$EnemyCollisionChecker
@onready var anim=$AnimatedSprite2D
var gamePaused:bool=true

func GetCollType(): #MUST HAVE
	return collType
	
func GetEnemyInfo():
	return enemyInfo

func SetGamePaused(pause:bool):
	gamePaused=pause

func _ready() -> void:
	enemyInfo=enemyInfo.duplicate()
	if enemyInfo.dead:
		TurnEnemyOff()
	
	spawnPositionLocal=position #MUST HAVE
	GlobalVariables.signal_IsPlayerInMenuChanged.connect(SetGamePaused)
	
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
	enemyCollider.set_deferred("disabled",true)
	enemyCollCheck.set_deferred("disabled",true)
	enemyCollCheck.set_deferred("monitoring",false)
	velocity=Vector2(0,0)
	
	
func Kill():
	enemyInfo.dead=true
	TurnEnemyOff()
	
func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead or gamePaused:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	move_and_slide()
	UpdateAnimations("idle")

func UpdateAnimations(_anim:String):
	anim.animation=_anim

func CheckOverlappingCollisions(): #MUST HAVE
	for n in enemyCollCheck.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(enemyInfo.damage)
	pass

func _on_enemy_collision_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)
	pass # Replace with function body.
