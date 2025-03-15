extends CharacterBody2D
class_name Base_Enemy

@export var collType:abstract_collidable #MUST HAVE
@export var enemyInfo:abstract_enemy #MUST HAVE
var spawnPositionLocal:Vector2
@onready var enemyCollider=$CollisionShape2D
@onready var enemyCollCheck=$EnemyCollisionChecker
@onready var anim:AnimatedSprite2D=$AnimatedSprite2D
var gamePaused:bool=true
var enemySleep:bool=true
@onready var positionLastFrame:Vector2=position
var isFalling:bool=false

var textbubble=preload("res://Scenes/UI/text_bubble.tscn")

@export var updateInterval:float=2
var updateCounter:float=0
var activeDistance:float=16*20

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
	enemyInfo.currentSpawnLocation=info.currentSpawnLocation
	enemyInfo.dead=info.dead

func GetIsFalling():
	#Make sure to update PositionLastFrame AFTER this
	var speed = abs(positionLastFrame-position)
	

	
	return speed.y>0.1
	
		
	
	
func DealDamage(value:int): #MUST HAVE
	if value>0:
		Kill()
		#TODO: Fancy kill animation

func TurnEnemyOff(hideInstantly:bool=true):
	if hideInstantly:
		hide()
	enemyCollider.set_deferred("disabled",true)
	enemyCollCheck.set_deferred("disabled",true)
	enemyCollCheck.set_deferred("monitoring",false)
	velocity=Vector2(0,0)
	
	
func Kill(showEffects:bool=true,soundToPlay:abstract_SoundEffectSetting.SoundEffectEnum=-1):
	

	
	if enemyInfo.dead:
		return
	enemyInfo.dead=true
	TurnEnemyOff(false)

	if showEffects:
		if soundToPlay!=-1:
			SoundManager.PlaySoundAtLocation(global_position,soundToPlay)
		anim.animation="death"
		var timeToDie:float=get_current_animation_length()		
		await get_tree().create_timer(timeToDie).timeout
	
	hide()
	
	if showEffects:
		var textBubbleInstance=textbubble.instantiate()
		textBubbleInstance.Setup(abstract_textEffect.effectEnum.STILL,text_bubble.behaviourEnum.FADE)
		textBubbleInstance.MoveUp=true
		textBubbleInstance.UseTypewriteEffect=true

		get_parent().add_child(textBubbleInstance)
		textBubbleInstance.global_position=global_position+Vector2(0,-16)
		
		var xp:int=GlobalVariables.AddXPFromKill(enemyInfo)
		
		textBubbleInstance.ShowText("+"+str(xp))
	
	#Spawn XP!

func get_current_animation_length(animated_sprite: AnimatedSprite2D = anim) -> float:

	var current_animation_name = animated_sprite.animation

	if current_animation_name == "":
		print("No animation is currently playing.")
		return -1.0
		
	var sprite_frames = animated_sprite.sprite_frames
	if sprite_frames and sprite_frames.has_animation(current_animation_name):
		var num_frames = sprite_frames.get_frame_count(current_animation_name)
		var anim_speed = animated_sprite.speed_scale * sprite_frames.get_animation_speed(current_animation_name)
		if anim_speed > 0:
			return num_frames / anim_speed
		else:
			print("Animation speed is zero or negative.")
		return -1.0
	else:
		print("Animation not found: ", current_animation_name)

	return -1.0



func CheckIfSleeping(delta:float):
	updateCounter+=delta
	
	if updateCounter>=updateInterval:
		updateCounter=0
		
		var playerpos= GlobalVariables.GetPlayerPosition()
		
		if playerpos.distance_to(global_position) > activeDistance or playerpos==Vector2(0,0):
			enemySleep=true
		else:
			enemySleep=false
			

func _physics_process(delta: float) -> void:
	
	if enemyInfo.dead or gamePaused:
		return
		
	CheckIfSleeping(delta)
	
	if enemySleep:
		return
	
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	
	isFalling = GetIsFalling()
	positionLastFrame=position #must be called before move_and_slide but after functions that need it

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
