extends Base_Enemy
class_name enemy_Fallblock

@onready var raycast=$Raaycast
@onready var impactEffect:AnimatedSprite2D=$ImpactEffect
var BlockDestroyer:crack_script

enum states{idle,fallprep,fall}
var state:states=states.fallprep
@export var timeBeforeFall:float=0.8
var timeBeforeFallCounter:float=0

var playImpactEffect:bool=false

var fallOrigin:Vector2
var distanceFallen:float=0
@export var blocksFallenBeforeBreaking:float=1.5


func _physics_process(delta: float) -> void:
	
	var animToPlay="idle"
	#self.sleeping=true
	
	if enemyInfo.dead:
		return
	# Add the gravity.
	
	match state:
		states.idle:
			pass
		states.fallprep:
			animToPlay="falling"
			velocity=Vector2(0,0)
			#sexy vibrations ;) 
			anim.position=Vector2(randf_range(-1,1),randf_range(-1,1))
			
			timeBeforeFallCounter+=delta
			
			if timeBeforeFallCounter>timeBeforeFall:
				timeBeforeFallCounter=0
				InitiateFall()
				
				
			pass
		states.fall:
			animToPlay="falling"

			var victims=CheckOverlappingCollisions()
			if victims !=null:
				for n in victims:
			
					#Handles flower murder
					if n.GetCollType().type==abstract_collidable.types.FLOWER:
						n.GetParent().DestroyFlower()
						continue
						pass
			
					#Makes player go above fallblock
					if n.GetCollType().type==abstract_collidable.types.PLAYER:
						n.global_position=self.global_position+Vector2(0,-16) #Hack to ensure player isn't stuck underneath block
					n.DealDamage(enemyInfo.damage)
					

					if n.GetCollType().type==abstract_collidable.types.ENEMY:
						

							
						var info:abstract_enemy
						info = n.enemyInfo
						
							#trigger steam achievement if fallblock kills something living ;) 
						if info.type != abstract_enemy.enemyTypes.FALLBLOCK and info.type!=abstract_enemy.enemyTypes.SPIKE:
							SteamHandler.TryUnlockAchievement("ach_fallblock")
						
						if info.type==abstract_enemy.enemyTypes.SPIKE:
							n.TurnEnemyOff()
						#custom murder
					
			else:
				move_and_slide()
				
			if  is_on_floor():
				state=states.idle
				animToPlay="idle"
				if playImpactEffect:
					PlayImpactEffect()
				elif state==states.idle and !playImpactEffect:
					playImpactEffect=true
				
				#Break blocks below if fallen far enough
				distanceFallen= abs(fallOrigin.y-global_position.y)
				if distanceFallen>blocksFallenBeforeBreaking*16:
					raycast.force_raycast_update()
					if raycast.is_colliding():
						if BlockDestroyer!=null:
							if BlockDestroyer.DestroyTileWithGlobalPosition(self.global_position+Vector2(0,16),true):
								state=states.fallprep
								animToPlay="falling"
								


			else:
				velocity.y += get_gravity().y * delta

	UpdateAnimations(animToPlay)

func InitiateFall():
	state=states.fall
	anim.position=Vector2(0,0)
	
	fallOrigin=global_position

	#If any fallblocks are above - tell them to also fall
	for n in $FallblockTrigger.get_overlapping_bodies():

		var enemy:abstract_enemy = n.GetEnemyInfo()
		if enemy.type==enemy.enemyTypes.FALLBLOCK:
			n.state=states.fallprep


func PlayImpactEffect():
	impactEffect.animation="destroy"
	impactEffect.play()
	SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.FALLBLOCK_LAND)
	pass


func CheckOverlappingCollisions():
	
	if state!=states.fall:
		return null
	
	var victims:Array[Node2D]

	#Checks if close to ground AND if the block has someone trapped beneath	
	
	#raycast.target_position=raycast.position+Vector2(0,16)
	raycast.force_raycast_update()
	
	#The raycast only checks for TILES to determine if it is within squichable range
	if  raycast.is_colliding():
		var distance:float=abs(raycast.global_position.y-raycast.get_collision_point().y)
		#$Label.text=str(distance)

		#$Sprite2D.global_position=
		if distance<10:
			for n in enemyCollCheck.get_overlapping_bodies():
				if n!=self:
					victims.append(n)
			
			if victims.size()>0:
				return victims

	
	return null


func _on_observer_block_destroyed() -> void:
	state=states.fallprep
	SoundManager.PlaySoundAtLocation(self.global_position,abstract_SoundEffectSetting.SoundEffectEnum.FALLBLOCK_FALLING_SHAKE)

	pass # Replace with function body.

func _on_enemy_collision_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$"." or state!=states.fall:
		return
	
	pass # Replace with function body.
