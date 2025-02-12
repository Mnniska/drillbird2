extends Node2D
class_name ore_sell_visualizer

signal finishedSelling(amount:int)
@onready var sprite=$oreSprite

var ore:abstract_ore


#MovementVariables
var targetPosition:Vector2
var hasTarget:bool=false
var velocity:Vector2=Vector2(0,0)
var friction:float=0.13
@export var SPEED=100

var timeBeforeSold:float=0.2
var timebeforesoldCounter:float=0

enum States{MOVING,WAITING,SOLD}
var state:States=States.WAITING

var textbubble=preload("res://Scenes/UI/text_bubble.tscn")
var textBubbleInstance:text_bubble

var isFinalHeart:bool=false
var startingShakePosition:Vector2


func Setup(_ore:abstract_ore,sellingPosition:Vector2,timeToWait:float):
	timeBeforeSold=timeToWait
	ore=_ore
	sprite.texture=ore.texture
	
	StartMoveToPosition(sellingPosition)
	pass

func StartMoveToPosition(_GlobalPos:Vector2):
	
	targetPosition=_GlobalPos
	hasTarget=true
	state=States.MOVING
	
	pass
	
func _process(delta: float) -> void:
	
	
	if state==States.MOVING:
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
			startingShakePosition=self.position
			state=States.WAITING

	if state==States.WAITING:

		timebeforesoldCounter+=delta
		
		#Item SHAKES right before it is sold
		if timeBeforeSold-timebeforesoldCounter<0.8:
			position=startingShakePosition+Vector2(randf_range(-1,1),randf_range(-1,1))

		if timebeforesoldCounter>timeBeforeSold:
			state=States.SOLD
			SellSelf()		
		pass

func SellSelf():
	if isFinalHeart:
		finishedSelling.emit(-1)
		$oreSprite.hide()
		await get_tree().create_timer(0.2).timeout
		queue_free()
	else:
		
		$destroyAnim.animation="sell"
		

		textBubbleInstance=textbubble.instantiate()
		textBubbleInstance.Setup(abstract_textEffect.effectEnum.STILL,text_bubble.behaviourEnum.FADE)
		textBubbleInstance.MoveUp=true
		textBubbleInstance.UseTypewriteEffect=true
		add_child(textBubbleInstance)
		textBubbleInstance.position+=Vector2(0,-16)
		textBubbleInstance.ShowText("+"+str(ore.value))
		
		finishedSelling.emit(ore.value)

		
		#TODO: Fancy sell effects
		$oreSprite.hide()
		await get_tree().create_timer(3).timeout
		queue_free()
