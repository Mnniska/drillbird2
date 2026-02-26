extends CharacterBody2D
class_name ghast

const SPEED = 300.0
const JUMP_VELOCITY = -400.0
var lineToFollow:Line2D=null

enum States{IDLE,FOLLOWINGLINE,PERSUIT,ARRIVED,DESPAWNING}
var state:States=States.IDLE
var TargetLocationGlobal:Vector2
var targetPoint:int=0
@export var idleSpeed:float=50
@onready var targetDebug:Node2D=$targetDebug

func _physics_process(delta: float) -> void:

	

	match state:
		States.IDLE:
			
			pass
		States.FOLLOWINGLINE:
			
			
			$Label.text=str(to_global(lineToFollow.get_point_position(0)))
			targetDebug.global_position=(TargetLocationGlobal)
			#targetDebug.global_position=Vector2(0,0)		
			var directionVector=global_position-TargetLocationGlobal
			var normalizedDirectionVector=directionVector.normalized()
			
			
			var movementVector:Vector2=idleSpeed*normalizedDirectionVector
			
			velocity.x=movementVector.x*-1
			velocity.y=movementVector.y*-1
			move_and_slide()
			

			if self.global_position.distance_to(TargetLocationGlobal)<10:
				targetPoint+=1
				if targetPoint>lineToFollow.get_point_count():
					targetPoint=0
				
				
				var newpos = to_global(lineToFollow.get_point_position(targetPoint))
				TargetLocationGlobal=newpos
				#get next point to follow
				
				pass
			pass



func SetupGhast(line:Line2D):
	lineToFollow=line
	

func TombstoneDestroyed():
	state=States.DESPAWNING
	#TODO: Despawn anim for X amount of time :) 
	self.queue_free()
	


func DetectedPlayer():
	pass

func LostTarget():
	
	pass

func NewTarget(Node2D):
	
	pass

func ReturnToLine():
	
	var distance=1000000
	var chosenPoint:Vector2=Vector2(0,0)
	for n in lineToFollow.get_point_count():
		var loc = to_global(lineToFollow.get_point_position(n)) 
		
		var dist = loc.distance_to(self.global_position)
		if dist<distance:
			distance=dist
			targetPoint=n
			chosenPoint=loc
	
	TargetLocationGlobal=chosenPoint
	#get the closest point in the line to return to
	
	state=States.FOLLOWINGLINE
	pass
