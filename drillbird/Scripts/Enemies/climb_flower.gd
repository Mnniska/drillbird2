extends Node2D
class_name climb_flower
@export var collider:abstract_collidable
@onready var vine:TextureRect=$vine
@onready var flower:AnimatedSprite2D=$Flower
var minsize:float=4
var size:float=4
var offset:Vector2=Vector2(0,4)
@export var SPEED:float=100

enum States{IDLE,MOVE_UP,MOVE_DOWN}
var state:States=States.IDLE
var restingPositionY=-4

var PlayerAttached:bool=false

func GetSelf():
	return self

func _process(delta: float) -> void:
	
	if PlayerAttached:
		state=States.MOVE_UP
	elif flower.position.y-offset.y<=restingPositionY:
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
	size+=delta*SPEED
	
	vine.set_size(Vector2(16,size))
	flower.position=offset+Vector2(0,-size)
	
	pass

func Move_DOWN(delta:float):
	size-=delta*SPEED*0.5
	size=max(minsize,size)
	vine.set_size(Vector2(16,size))
	flower.position=offset+Vector2(0,-size)
	pass

func UpdateAnimations():
	
	match state:
		States.IDLE:
			flower.animation="idle"
		States.MOVE_UP:
			flower.animation="movingup"
		States.MOVE_DOWN:
			flower.animation="idle"
	pass

func GetFlowerPosition():
	return flower.global_position

func SetPlayerAttached(attached:bool):
	PlayerAttached=attached
