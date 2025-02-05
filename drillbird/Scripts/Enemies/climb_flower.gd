extends Node2D
class_name climb_flower
@export var collider:abstract_collidable
@onready var vine:TextureRect=$vine
@onready var flowerAnim:AnimatedSprite2D=$FlowerBody/FlowerAnim
@onready var flowerBody:RigidBody2D=$FlowerBody

var size:float=4
var offset:Vector2=Vector2(0,4)
@export var SPEED:float=20

enum States{IDLE,MOVE_UP,MOVE_DOWN}
var state:States=States.IDLE
var restingPositionY=-4

var PlayerAttached:bool=false

func GetSelf():
	return self

func _process(delta: float) -> void:
	

	
	if PlayerAttached:
		state=States.MOVE_UP
	elif flowerBody.position.y-offset.y<=restingPositionY:
		state=States.MOVE_DOWN
	else:
		state=States.IDLE
	
	match state:
		States.IDLE:
			Move_IDLE(delta)
		States.MOVE_UP:
			Move_UP(delta)
		States.MOVE_DOWN:
			Move_DOWN(delta)

	UpdateAnimations()

func GetCollType():
	return collider

func Move_IDLE(delta:float):
	
	pass

func Move_UP(delta:float):
	
	var distance=flowerBody.global_position.distance_to(global_position)
	
	vine.set_size(Vector2(16,distance+offset.y))
	
	
	flowerBody.move_and_collide(Vector2(0,-SPEED*delta))
	
	
	
	pass

func Move_DOWN(delta:float):

	
	var distance=flowerBody.global_position.distance_to(global_position)
	
	vine.set_size(Vector2(16,distance+offset.y))
	
	flowerBody.move_and_collide(Vector2(0,SPEED*0.5*delta))
	
	pass

func UpdateAnimations():
	
	match state:
		States.IDLE:
			flowerAnim.animation="idle"
		States.MOVE_UP:
			flowerAnim.animation="movingup"
		States.MOVE_DOWN:
			flowerAnim.animation="idle"
	pass

func GetFlowerPosition():
	return flowerBody.global_position

func SetPlayerAttached(attached:bool):
	PlayerAttached=attached
