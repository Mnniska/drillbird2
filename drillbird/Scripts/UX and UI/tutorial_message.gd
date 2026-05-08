extends Node2D
class_name tutorial_message
@export var timeBeforeMessageShows:float=3
@onready var textBubble:text_bubble=$TextBubble
@onready var timer=$Timer
@export var textToShow:String="undefined"
@export var pauseTimerWhenNotInArea:bool=true
@export var tutorialActive:bool=true
var textShown:bool=false
var passedTest:bool=false


@onready var collisionShapeThatPassesTest:Area2D=$"pass test collider"
@export var passTestViaCollider:bool=false
@export var BeginTimerWhenEntered:bool=true:
	get: return BeginTimerWhenEntered
	set(value): 
		BeginTimerWhenEntered=value
		if BeginTimerWhenEntered==true:
			CheckCollisions()

signal DisplayedMessage
signal TimerStarted

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	$Timer.wait_time=timeBeforeMessageShows
	textBubble.Setup(abstract_textEffect.effectEnum.STILL,text_bubble.behaviourEnum.STAY)
	
	if collisionShapeThatPassesTest and passTestViaCollider:
		collisionShapeThatPassesTest.body_shape_entered.connect(PassedTestBodyEntered)
	
	if !passTestViaCollider:
		collisionShapeThatPassesTest.queue_free()
	
	pass # Replace with function body.

func PassedTestBodyEntered(_body_rid:RID,_body:Node2D,_body_shape_index:int,_local_shape_index:int) -> void:
	PassedTest()
	




func PassedTest():
	if !passedTest:
		passedTest=true
		
		StopTimer()
		if textShown:
			textBubble.Setup(abstract_textEffect.effectEnum.WAVE,text_bubble.behaviourEnum.FADE)
			textBubble.ShowText(tr("tut_passed"))
	
	pass

func TriggerText():
	textBubble.ShowText(textToShow)
	timer.stop()
	textShown=true
	DisplayedMessage.emit()

	pass
	
func StopTimer():
	timer.stop()
	
	pass

func PlayerEnteredArea():
	if !textShown && !passedTest && BeginTimerWhenEntered:

		timer.start(timer.time_left)
		timer.paused=false
		TimerStarted.emit()
	
	pass

func CheckCollisions():
	var yes:bool=false
	for n in $Area2D.get_overlapping_bodies():
		yes=true
	if yes:
		PlayerEnteredArea()
	pass



func _on_area_2d_body_shape_entered(_body_rid:RID,_body:Node2D,_body_shape_index:int,_local_shape_index:int) -> void:
	if tutorialActive:
		PlayerEnteredArea()
	
	pass # Replace with function body.


func _on_area_2d_body_shape_exited(_body_rid:RID,_body:Node2D,_body_shape_index:int,_local_shape_index:int) -> void:
	if pauseTimerWhenNotInArea:
		timer.paused=true
	pass # Replace with function body.


func _on_timer_timeout() -> void:
	if tutorialActive:
		TriggerText()
	pass # Replace with function body.
