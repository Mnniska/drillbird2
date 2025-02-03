extends Node2D

var targetActor:Node2D

#MovementVariables
var targetPosition:Vector2
var hasTarget:bool=false
var velocity:Vector2=Vector2(0,0)
var friction:float=0.13
@export var SPEED=100
@export var noiseAmount:float=0.5
var toEgg:bool=true



func MoveToPosition(pos:Vector2):
	toEgg=true
	targetPosition=pos
	
	while global_position!=targetPosition:
		var rand=Vector2(randf_range(-noiseAmount,noiseAmount),randf_range(-noiseAmount,noiseAmount))

		global_position=global_position.lerp(targetPosition,0.003)+rand
		await get_tree().create_timer(1/60).timeout
	
	pass
	
func MoveToObject(node:Node2D):
	toEgg=false
	targetActor=node
	
	
	while global_position.distance_to(targetActor.global_position)>noiseAmount:
		var rand=Vector2(randf_range(-noiseAmount,noiseAmount),randf_range(-noiseAmount,noiseAmount))

		global_position=global_position.lerp(targetActor.global_position,0.003)+rand
		await get_tree().create_timer(1/60).timeout
	
	pass
