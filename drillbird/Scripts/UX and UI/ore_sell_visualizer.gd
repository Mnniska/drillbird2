extends Node2D
class_name ore_sell_visualizer

signal finishedSelling(amount:int)
@onready var sprite=$oreSprite

var ore:abstract_ore
@export var movementCurve:Curve
@export var chillBeforeMovingCurve:Curve
var chillprogress:float=0
@export var timeBeforeMovingWhenChilling:float=1.2

#MovementVariables
var startingPos:Vector2
var totalDistanceToTravel:float
var targetPosition:Vector2
var hasTarget:bool=false
var velocity:Vector2=Vector2(0,0)
var friction:float=0.13
@export var SPEED=150

var timeBeforeSold:float=0.2
var timebeforesoldCounter:float=0

enum States{MOVING,WAITING,SOLD,CHILLING}
var state:States=States.WAITING

var textbubble=preload("res://Scenes/UI/text_bubble.tscn")
var textBubbleInstance:text_bubble

var isFinalHeart:bool=false
var startingShakePosition:Vector2


func Setup(_ore:abstract_ore,sellingPosition:Vector2,timeToWait:float=1,speedMult:float=1,chillBeforeMoving:bool=false):
	startingPos=global_position
	SPEED=SPEED*speedMult
	timeBeforeSold=timeToWait
	ore=_ore
	sprite.texture=ore.texture
	targetPosition=sellingPosition
	
	if chillBeforeMoving:
		state=States.CHILLING
		
	else:
		StartMoveToPosition()
	pass



func StartMoveToPosition():
	
	totalDistanceToTravel=self.global_position.distance_to(targetPosition)
	hasTarget=true
	state=States.MOVING
	
	pass
	
func _process(delta: float) -> void:
	
	if state==States.CHILLING:
		chillprogress+=delta
		var prog=chillprogress/timeBeforeMovingWhenChilling
		global_position=startingPos+Vector2(0,-chillBeforeMovingCurve.sample(prog))
		
		if prog>=1:
			StartMoveToPosition()
	
	if state==States.MOVING:
		var currentDist=self.global_position.distance_to(targetPosition)
		var progress=currentDist/totalDistanceToTravel
		
		var speedMult=movementCurve.sample(progress)
		speedMult=max(0.1,speedMult)
		var movevector= global_position.direction_to(targetPosition)
		velocity=movevector*SPEED*delta*speedMult
	
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
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_GIVEORE_RISER)

	if state==States.WAITING:

		timebeforesoldCounter+=delta
		
		#Item SHAKES right before it is sold
		if timeBeforeSold-timebeforesoldCounter<0.8:
			position=startingShakePosition+Vector2(randf_range(-1,1),randf_range(-1,1))

		if timebeforesoldCounter>timeBeforeSold:
			state=States.SOLD
			SellSelf()		
		pass

func SellSelf(skipBubble:bool=false):
	
	if isFinalHeart:
		finishedSelling.emit(-1)
		$oreSprite.hide()
		await get_tree().create_timer(0.2).timeout
		queue_free()
		
	else:
	
		$destroyAnim.animation="sell" #Todo: probably variant of this when goiing into inventory
		
		if !skipBubble:
			textBubbleInstance=textbubble.instantiate()
			textBubbleInstance.Setup(abstract_textEffect.effectEnum.STILL,text_bubble.behaviourEnum.FADE)
			textBubbleInstance.MoveUp=true
			textBubbleInstance.UseTypewriteEffect=true
			add_child(textBubbleInstance)
			textBubbleInstance.position+=Vector2(0,-16)
			textBubbleInstance.ShowText("+"+str(ore.value))
		
		finishedSelling.emit(ore.value)
		$oreSprite.hide()
		await get_tree().create_timer(3).timeout
		queue_free()
