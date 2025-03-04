extends Node2D
class_name climb_flower
@export var collider:abstract_collidable
@onready var vine:TextureRect=$vine
@onready var flowerAnim:AnimatedSprite2D=$FlowerBody/FlowerAnim
@onready var flowerBody:RigidBody2D=$FlowerBody
@onready var raycast:RayCast2D=$canFlowerRaycast


@onready var flowerAttachedSound:sound_looper=$SoundLooper
var positionLastFrame:Vector2


var size:float=4
var offset:Vector2=Vector2(0,4)
@export var SPEED:float=20
@export var MAXSPEEDMULTIPLIER:float=2
@export var timeUntilFast:float=5
var speedTimeCounter:float=0

var currentSpeed=SPEED

enum States{ IDLE, MOVE_UP, MOVE_DOWN, GROWING}
var state:States=States.IDLE
var restingPositionY=-4

var PlayerAttached:bool=false

@export var flowerGrowTimer:float=3
var flowerGrowCount:float=0
var isBeingNurtured:bool=false
@onready var FlowerRootAnim:AnimatedSprite2D=$base

func _ready() -> void:
	GlobalVariables.PlayerIsDrillingTileChanged.connect(PLayerDrillingTileChange)
	
func PLayerDrillingTileChange(drilling:bool):
	if !drilling:
		isBeingNurtured=false
	pass

func GetSelf():
	return self

func _process(delta: float) -> void:
	
	if state!=States.GROWING:
		Update_Active(delta)
	else:
		Update_Growing(delta)



func Update_Growing(delta:float):
	
	
	if isBeingNurtured:
		flowerGrowCount+=delta
		UpdateRootSprites(flowerGrowCount/flowerGrowTimer)
		if flowerGrowCount>flowerGrowTimer:
		
			if !raycast.is_colliding():
				SetHasBlossomed(true)
			else:
				flowerGrowCount=flowerGrowTimer
	else:
		flowerGrowCount-=delta
		UpdateRootSprites(flowerGrowCount/flowerGrowTimer)
		if flowerGrowCount<0:
			queue_free()

func UpdateRootSprites(_progress:float):
	var amountOfSprites:float=5
	
	var chosenSprite=floori(amountOfSprites*_progress)
	FlowerRootAnim.animation="growing"
	FlowerRootAnim.frame=chosenSprite
	
	
	pass



func Update_Active(delta:float):
	if PlayerAttached:
		if state!=States.MOVE_UP:
			state=States.MOVE_UP
			SoundManager.PlaySoundAtLocation(flowerBody.global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_GRAB_FLOWER)
	elif flowerBody.position.y-offset.y<=restingPositionY:
		if state!=States.MOVE_DOWN:
			state=States.MOVE_DOWN
			flowerAttachedSound.Stop()
	else:
		if state!=States.IDLE:
			state=States.IDLE
	
	match state:
		States.IDLE:
			Move_IDLE(delta)
		States.MOVE_UP:
			Move_UP(delta)
		States.MOVE_DOWN:
			Move_DOWN(delta)

	UpdateAnimations()
	pass
	
	
func SetHasBlossomed(hasBlossomed:bool):
	if hasBlossomed:
		state=States.IDLE
		FlowerRootAnim.animation="idle"
		flowerBody.SetActive(true)
		vine.show()
	else:
		flowerBody.SetActive(false)
		state=States.GROWING
		vine.hide()
	
	pass

func GetCollType():
	return collider

func Move_IDLE(delta:float):
	speedTimeCounter=0
	pass

func Move_UP(delta:float):
	
	var distance=flowerBody.global_position.distance_to(global_position)
	
	vine.set_size(Vector2(16,distance+offset.y))
	
	speedTimeCounter=min(timeUntilFast,speedTimeCounter+delta)
	var progress=speedTimeCounter/timeUntilFast
	currentSpeed=SPEED*(1+(MAXSPEEDMULTIPLIER*progress))
	
	var minpitch=1
	var maxpitch=1.3
	var pitchP=lerpf(minpitch,maxpitch,progress)
	flowerAttachedSound.SetPitch(pitchP)
	flowerBody.move_and_collide(Vector2(0,-currentSpeed *delta))
	UpdateMoveSound()

func UpdateMoveSound():
	
	var moveSinceLastFrame=positionLastFrame.y- flowerBody.position.y
	if moveSinceLastFrame>0.05:
		
		flowerAttachedSound.Play()
	else:
		flowerAttachedSound.Stop()

	
	positionLastFrame=flowerBody.position
	pass

func Move_DOWN(delta:float):

	speedTimeCounter=0
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
