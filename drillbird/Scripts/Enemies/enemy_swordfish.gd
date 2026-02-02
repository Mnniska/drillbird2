extends Base_Enemy
class_name enemy_swordfish

const SPEED = 40.0
const ATTACK_SPEED=120
const JUMP_VELOCITY = -400.0
const DAZED_TIME=2

enum States{WALK,WAIT,DETECT, ATTACK, DAZED}
var state:States=States.WALK
var direction:float=1

@export var reactionTime:float=1.2
@export var timeInWait:float=0.4
@export var timeBeforeTurning:float=0.2
var turningCounter:float=0
var waitCounter=0
var speed:Vector2=Vector2(0,0)


@onready var detectionArea=$DetectionArea
@onready var attackCollisionArea=$ChargeAttackCollider
@onready var lineOfSightRaycast=$LineOfSightRaycast

#This variable is assigned via the EnemySpawn script when this bad boi is spawned
var BlockDestroyer:crack_script

func _ready() -> void:
	GlobalVariables.TileDestroyed.connect(TileWasDestroyed)
	
	
	
	
func TileWasDestroyed():
	if enemyInfo.dead or gamePaused or enemySleep or state==States.DETECT or state==States.ATTACK or state==States.DAZED:
		return
	
	if GlobalVariables.PlayerController.position.distance_to(self.position)<16*5:
		
		#we wait a short moment here to ensure that the destroyed tile is properly destroyed 
		await get_tree().create_timer(0.05).timeout
		
		CheckIfPlayerIsInDetectionZone()
		
		pass
	
	pass

func _physics_process(delta: float) -> void:
	

	
	$Label.text=anim.animation
	
	if enemyInfo.dead or gamePaused:
		return
	
	CheckIfSleeping(delta)
	if enemySleep:
		return	

	if not is_on_floor() and state!=States.ATTACK:
		velocity += get_gravity() * delta * 0.3


	var animToPlay=anim.animation

	move_and_slide()

	if state==States.WALK:
		animToPlay="run"
		
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
		animToPlay="idle"
		waitCounter+=delta
		if waitCounter>timeInWait:
			waitCounter=0
			state=States.WALK

	if state==States.DETECT:
		animToPlay="detect"
		velocity.x=0
		pass
		#I don't think I need to do a lot here except play the detect anim

	if state==States.ATTACK:
		animToPlay="sprint"
		velocity.x=direction*ATTACK_SPEED
		
		#here I should prolly do a raycast..check if there's anything in frooont of the enemy? 
		#Could also have a regular collider right in front of the enemy, so we wait for a collision there?
		#Can regular colliders collide with tiles? I'm pretty sure they can
		

	#Done at the end of upate, used in the next loop
	
	if GetIsFalling():
		if !isFalling:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_GENERIC_FALL)
		isFalling=true
	else:
		isFalling=false
	
	if isFalling:
		animToPlay="fall"
	
	
	positionLastFrame=position
	UpdateAnimations(animToPlay)

func UpdateAnimations(_anim:String):
	
	if anim.animation!=_anim:
		anim.animation=_anim
	anim.flip_h=direction < 0
	if detectionArea.scale.x!=direction:
		detectionArea.scale.x=direction
		attackCollisionArea.scale.x=direction
		lineOfSightRaycast.scale.x=direction
		
	pass

func SpotPlayer():
	if state!=States.ATTACK and state!=States.DETECT:
		

		lineOfSightRaycast.force_raycast_update()

		var collider:Node2D=lineOfSightRaycast.get_collider()
		
		#Check if there's environment blocking the view to see the player.
		#The enemy can see thru everything except the objects in TilemapEnvironment
		
		if collider!=null:
			if collider.name=="TilemapEnvironment":
				return
		
		state=States.DETECT
		anim.animation="detect"
		await get_tree().create_timer(reactionTime).timeout
		state=States.ATTACK

func HitWithAttack(body:Node2D):
	
	body.get_path()
	if body.name=="TilemapEnvironment":
		
		if BlockDestroyer!=null:
			BlockDestroyer.DestroyTileWithGlobalPosition(Vector2(self.global_position.x+16*direction,global_position.y),true)
		
		pass
		#Destroy the tile lol
	else:
		var colltype:abstract_collidable
		colltype=body.GetCollType()
		
		body.DealDamage(enemyInfo.damage)
		
	
	
	state=States.DAZED
	anim.animation="dazed"
	velocity.x=0
	await get_tree().create_timer(DAZED_TIME).timeout
	
	direction=direction*-1
	
	if !CheckIfPlayerIsInDetectionZone():
		state=States.WALK
	pass

func CheckIfPlayerIsInDetectionZone():
	
	var collisions:Array[Node2D]= detectionArea.get_overlapping_bodies()
	
	if collisions.size()>0:
		var colltype:abstract_collidable
		for n in collisions:
			colltype=n.GetCollType()
			if colltype.type==colltype.types.PLAYER:
				SpotPlayer()
				return true
	
	return false
	

func _on_enemy_collision_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)


func _on_detection_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	

	SpotPlayer()
	
	pass # Replace with function body.


func _on_charge_attack_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
		
	if state!=States.ATTACK:
		return
	
	HitWithAttack(body)

	
	pass # Replace with function body.
