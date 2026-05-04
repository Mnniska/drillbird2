extends Base_Enemy
class_name enemy_swordfish

const SPEED = 40.0
const ATTACK_SPEED=120
const JUMP_VELOCITY = -400.0
const DAZED_TIME=2.1
var dazedCounter:float=0
const DAZED_TIME_WHILE_FALLING:float=0.35

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

@onready var tileBelowRaycast=$LedgeChecker/TileBelowRaycast

var levitatingAfterHit:bool=false

#This variable is assigned via the EnemySpawn script when this bad boi is spawned
var BlockDestroyer:crack_script

func _ready() -> void:
	GlobalVariables.TileDestroyed.connect(TileWasDestroyed)
	
func DebugShowMessage(text:String):
	
	var textBubbleInstance=textbubble.instantiate()
	textBubbleInstance.Setup(abstract_textEffect.effectEnum.STILL,text_bubble.behaviourEnum.FADE)
	textBubbleInstance.MoveUp=true
	textBubbleInstance.UseTypewriteEffect=false

	get_parent().add_child(textBubbleInstance)
	textBubbleInstance.global_position=global_position+Vector2(0,-16)
	
	textBubbleInstance.ShowText(text)
	
	pass
	
	
func TileWasDestroyed():
	#This signal is here because when the player destroys a tile and is in the swordfishes vision range, I want the swordfish to spot the player
	#However, since the player has already entered their detection zone, they'll miss the player. 
	#So whenever player destroys a tile, I check if the tile is nearby the swordfish and run a detection test
	
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

	if not is_on_floor() and state!=States.ATTACK and !levitatingAfterHit:
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
		

	if state==States.DAZED:
		
		if GetIsFalling():
			
			#only let the counter go to a treshhold, then wait for fish to land b4 continuing
			if dazedCounter<DAZED_TIME_WHILE_FALLING:
				dazedCounter+=delta
			
			if anim.frame>2:
				anim.frame=2
				anim.speed_scale=0
		else:
			dazedCounter+=delta
			anim.speed_scale=1
				

		#Fish has finished resting after being dazed	
		if dazedCounter>=DAZED_TIME:
			dazedCounter=0
			direction=direction*-1
	
			if !CheckIfPlayerIsInDetectionZone():
				state=States.WALK
				animToPlay="run"


	#Done at the end of upate, used in the next loop
	
	if GetIsFalling():
		if !isFalling:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ENEMY_GENERIC_FALL)
		isFalling=true
	else:
		isFalling=false
	
	if isFalling:
		
		#todo: have fall anim be different if falling while in dazed state versus falling normally (will fish ever fall normally..? Yeah if the tile below it is destroyed
		#todo: When in dazed state, pause daze counter while falling
		if state!=States.DAZED:
			animToPlay="fall"
		velocity.x=0
	
	
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
		$LedgeChecker.scale.x=direction
		
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
			BlockDestroyer.DestroyTileWithGlobalPosition(Vector2(self.global_position.x+16*direction,global_position.y),true,true)
		
	else:
		
		body.DealDamage(enemyInfo.damage)
		
	
	
	state=States.DAZED
	anim.animation="dazed"
	velocity.x=0
	dazedCounter=0
	
	levitatingAfterHit=true
	await get_tree().create_timer(0.2).timeout
	levitatingAfterHit=false
	
	#What remains is for the counter to run out, and then enter normal walk
	#However, since the fish can fall while dazed, we can't do a hard counter - we wanna pause the fish while falling
	#So the rest of dazed is handled in the physics update
	

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

func TurnEnemyOff(hideInstantly:bool=true):
	if hideInstantly:
		hide()
	enemyCollider.set_deferred("disabled",true)
	enemyCollCheck.set_deferred("disabled",true)
	enemyCollCheck.set_deferred("monitoring",false)
	
	attackCollisionArea.set_deferred("disabled",true)
	attackCollisionArea.set_deferred("monitoring",false)
	
	#yo couldn't we just destroy the enemy here? It's weird that we're just hiding it imo
	
	velocity=Vector2(0,0)	

func _on_enemy_collision_checker_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)


func _on_detection_area_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body==$".":
		return
	

	SpotPlayer()
	
	pass # Replace with function body.


func _on_charge_attack_collider_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body==$".":
		return
		
	if state!=States.ATTACK:
		return
	
	HitWithAttack(body)

	
	pass # Replace with function body.



func _on_ledge_checker_body_exited(_body: Node2D) -> void:

	if !tileBelowRaycast.get_collider():
	
		if state==States.WALK:
			direction=direction*-1
			state=States.WAIT
			velocity.x=0
	
	
	pass # Replace with function body.
