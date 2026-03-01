extends CharacterBody2D
class_name ghast

@export var collType:abstract_collidable #MUST HAVE
@export var enemyInfo:abstract_enemy #MUST HAVE

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const PERSUIT_SPEED=50

const PERSUIT_LENGTH = 16*10

var lineToFollow:Line2D=null
var tombstone:Node2D=null

enum States{IDLE,FOLLOWINGLINE,PERSUIT,ARRIVED,DESPAWNING}
var state:States=States.IDLE
var TargetLocationGlobal:Vector2
var targetPoint:int=0
var targetBody:Node2D=null

@export var idleSpeed:float=50
@onready var targetDebug:Node2D=$targetDebug

func _physics_process(delta: float) -> void:

	

	match state:
		States.IDLE:
			
			pass
		States.FOLLOWINGLINE:
			
			
			
			targetDebug.global_position=(TargetLocationGlobal)
			#targetDebug.global_position=Vector2(0,0)		
			
			var movementVector:Vector2=idleSpeed*GetMovementVector(TargetLocationGlobal)
			
			velocity.x=movementVector.x*-1
			velocity.y=movementVector.y*-1
			move_and_slide()
			

			if self.global_position.distance_to(TargetLocationGlobal)<10:
				targetPoint+=1
				if targetPoint>lineToFollow.get_point_count()-1:
					targetPoint=0
				
				
				var newpos = tombstone.global_position+lineToFollow.get_point_position(targetPoint)
				TargetLocationGlobal=newpos
				#get next point to follow
				
				pass
		States.PERSUIT:
			
			var movement = PERSUIT_SPEED*GetMovementVector(targetBody.global_position)
			velocity.x=movement.x*-1
			velocity.y=movement.y*-1
			move_and_slide()
			
			if global_position.distance_to(tombstone.global_position)>PERSUIT_LENGTH:
				AbortChaseDueToDistance()

			pass

func AbortChaseDueToDistance():
	state=States.IDLE
	$Label.text="aborted"
	await get_tree().create_timer(0.6).timeout
	$Label.text="returning"
	ReturnToLine()

func GetMovementVector(_targetPosGlobal:Vector2):
	
	
	var directionVector=global_position - _targetPosGlobal
	var normalizedDirectionVector=directionVector.normalized()
	return normalizedDirectionVector

func SetupGhast(line:Line2D , _tombstone:Node2D):
	lineToFollow=line

	tombstone=_tombstone
	

func TombstoneDestroyed():
	state=States.DESPAWNING
	#TODO: Despawn anim for X amount of time :) 
	self.queue_free()
	


func DetectedPlayer():
	pass

func LostTarget():
	
	pass

func NewTarget(body:Node2D):
	
	if global_position.distance_to(tombstone.global_position)>=PERSUIT_LENGTH:
		return
		
	targetBody=body
	state=States.PERSUIT
	$Label.text="chasing"
	
	
	pass

func ReturnToLine():
	
	var distance=1000000
	var chosenPoint:Vector2=Vector2(0,0)
	for n in lineToFollow.get_point_count():
		var loc = tombstone.global_position+lineToFollow.get_point_position(n) 
		
		var dist = loc.distance_to(self.global_position)
		if dist<distance:
			distance=dist
			targetPoint=n
			chosenPoint=loc
	
	TargetLocationGlobal=chosenPoint
	#get the closest point in the line to return to
	
	state=States.FOLLOWINGLINE
	pass


func _on_detection_radius_body_entered(body: Node2D) -> void:
	if state!=States.ARRIVED:
		
		NewTarget(body)
	else:
		pass
		#check if the new body is higher prio then the old one, if so persue that one
	
	
	pass # Replace with function body.


func _on_collider_enemy_hitbox_body_entered(body: Node2D) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)
	
	pass # Replace with function body.
