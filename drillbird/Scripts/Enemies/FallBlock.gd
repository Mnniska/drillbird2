extends "res://Scripts/Enemies/BaseEnemy.gd"
class_name enemy_Fallblock

@onready var raycast=$Raaycast
@onready var impactEffect:AnimatedSprite2D=$ImpactEffect
var BlockDestroyer:crack_script

var isFalling:bool=false
enum states{idle,fallprep,fall}
var state:states=states.fall
@export var timeBeforeFall:float=0.8
var timeBeforeFallCounter:float=0
var fast:bool=false



func InitiateFall():
	state=states.fall
			
	anim.position=Vector2(0,0)
	fast=GetWillBeFast()

	#If any fallblocks are above - tell them to also fall
	for n in $FallblockTrigger.get_overlapping_bodies():

		var enemy:abstract_enemy = n.GetEnemyInfo()
		if enemy.type==enemy.enemyTypes.FALLBLOCK:
			n.state=states.fallprep
	pass

func _physics_process(delta: float) -> void:
	
	
	#self.sleeping=true
	
	if enemyInfo.dead:
		return
	# Add the gravity.
	
	match state:
		states.idle:
			pass
		states.fallprep:
			velocity=Vector2(0,0)
			#sexy vibrations ;) 
			anim.position=Vector2(randf_range(-1,1),randf_range(-1,1))
			
			timeBeforeFallCounter+=delta
			
			if timeBeforeFallCounter>timeBeforeFall:
				timeBeforeFallCounter=0
				InitiateFall()
				
				
			pass
		states.fall:
			
			var victims=CheckOverlappingCollisions()
			if victims !=null:
				for n in victims:
			
					n.global_position=self.global_position+Vector2(0,-16) #Hack to ensure player isn't stuck underneath block
					n.DealDamage(enemyInfo.damage)
			else:
				move_and_slide()
				
			if  is_on_floor():
				state=states.idle
				PlayImpactEffect()
				if fast && raycast.is_colliding():
					if BlockDestroyer!=null:
						if BlockDestroyer.DestroyTileWithGlobalPosition(self.global_position+Vector2(0,16),true):
							state=states.fallprep
					

			else:
				velocity += get_gravity() * delta

	UpdateAnimations("idle")

func PlayImpactEffect():
	impactEffect.animation="destroy"
	impactEffect.play()
	pass

func GetWillBeFast():
	var tilesBeforeFast:float=1.5
	raycast.target_position=raycast.position+Vector2(0,tilesBeforeFast*16)
	raycast.force_raycast_update()
	if raycast.is_colliding():
		raycast.target_position=raycast.position+Vector2(0,15)
		return false
	else:
		raycast.target_position=raycast.position+Vector2(0,15)
		return true


func CheckOverlappingCollisions():
	
	if state!=states.fall:
		return null
	
	var victims:Array[Node2D]

	#Checks if close to ground AND if the block has someone trapped beneath	
	
	#raycast.target_position=raycast.position+Vector2(0,16)
	raycast.force_raycast_update()
	
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
	pass # Replace with function body.

func _on_enemy_collision_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$"." or state!=states.fall:
		return
	
	pass # Replace with function body.