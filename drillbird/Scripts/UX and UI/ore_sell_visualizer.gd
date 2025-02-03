extends Node2D
class_name ore_sell_visualizer
@onready var sprite=$oreSprite
var ore:abstract_ore

#MovementVariables
var targetPosition:Vector2
var hasTarget:bool=false
var velocity:Vector2=Vector2(0,0)
var friction:float=0.13
@export var SPEED=100

@export var idleMoveTimerTarget:float=0.5
var idleMoveCount=0
var moveDir:float=1




func Setup(_ore:abstract_ore):
	ore=_ore
	sprite.texture=ore.texture
	pass

func StartMoveToPosition(_GlobalPos:Vector2):
	
	targetPosition=_GlobalPos
	hasTarget=true
	
	pass
	
func _process(delta: float) -> void:
	
	if hasTarget:
		
		
		
		var movevector= global_position.direction_to(targetPosition)
		velocity=movevector*SPEED*delta
	
		global_position+=velocity
		velocity.x-=friction
		velocity.y-=friction
	
		var buffer=3
		if velocity.x<=0.1 && global_position.distance_to(targetPosition)<=buffer:
			hasTarget=false
			velocity.y=0
			velocity.x=0
			velocity.y=SPEED*delta*moveDir

			
			
	else:
		
		idleMoveCount+=delta
		
		var floatdist=4
		var target=targetPosition+Vector2(0,floatdist*moveDir)
		var start=targetPosition+Vector2(0,floatdist*moveDir*-1)
		
		var progress=idleMoveCount/idleMoveTimerTarget
		global_position= start.lerp(target,progress)
		if idleMoveCount>idleMoveTimerTarget:
			idleMoveCount=0
			moveDir*=-1

		#MoveUpAndDown
		
		pass

func SellSelf():
	#TODO: Fancy sell effects
	sprite.hide()
	return ore.value
