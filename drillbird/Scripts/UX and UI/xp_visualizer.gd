extends Node2D

var targetActor:Node2D

#MovementVariables
var targetPosition:Vector2
var hasTarget:bool=false

var velocity:Vector2=Vector2(0,0)
var friction:float=0.13
@export var SPEED=100
@export var noiseAmount:float=0.5
var MovingToObject:bool=true



func _physics_process(delta: float) -> void:
	
	if hasTarget:
		
		if MovingToObject:
			targetPosition=targetActor.global_position
		
		var movevector= global_position.direction_to(targetPosition)
		velocity=movevector*SPEED*delta
	
		global_position+=velocity
		velocity.x-=friction
		velocity.y-=friction
		
		var rand=Vector2(randf_range(-noiseAmount,noiseAmount),randf_range(-noiseAmount,noiseAmount))
		global_position+=rand
	
		
	pass

func MoveToPosition(pos:Vector2):
	hasTarget=true
	MovingToObject=false
	targetPosition=pos

	pass
	
func MoveToObject(node:Node2D):
	hasTarget=true
	MovingToObject=true
	targetActor=node
	
	
	pass
