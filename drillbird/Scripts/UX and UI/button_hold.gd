extends Node2D
class_name button_hold

@export var textID_hold:String=""
@export var textID_toDoX:String=""

@export var holdTime:float=1.5
@onready var text_hold=$HBoxContainer/text_hold
@onready var text_toendday=$HBoxContainer/text_toEndDay
@onready var icon=$HBoxContainer/iconHolder/icon
@onready var icon_filler=$HBoxContainer/iconHolder/icon/active

var holdCounter:float=0
var buttonActive:bool=false
var pressed:bool=false

enum directions{up,down}
@export var dirToHold:directions=directions.up:
	get: return dirToHold
	set(value):
		dirToHold=value


signal buttonPressed
signal buttonProgressChanged(progress:bool)

func SetupIconDirection():
	if dirToHold==directions.up:	
		icon.rotation=0

	if dirToHold==directions.down:
		icon.rotation_degrees=180

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetupIconDirection()
	pass # Replace with function body.
	

func SetActive(_active:bool):
	
	text_hold.text=tr(textID_hold)
	text_toendday.text=tr(textID_toDoX)
	
	buttonActive=_active
	if buttonActive and GlobalVariables.displayPopups:
		show()
	else:
		hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !buttonActive:
		return
		
	if dirToHold==directions.up:
		if Input.is_action_pressed("up"):
			ProgressButtonHeld(true,delta)
		else:
			ProgressButtonHeld(false,delta)
	
	if dirToHold==directions.down:
		if Input.is_action_pressed("down"):
			ProgressButtonHeld(true,delta)
		else:
			ProgressButtonHeld(false,delta)


func SetHoldProgress(progress:float):
	var min = 15
	var pos=lerp(min,0,progress)
	icon_filler.position.y=pos

func ProgressButtonHeld(buttonHeld:bool,delta:float):
	if pressed!=buttonHeld:
		#Signals the button is being progressed. This is used for transitioning music
		pressed=buttonHeld
		buttonProgressChanged.emit(pressed)
	
	if buttonHeld:
		holdCounter+=delta
	elif holdCounter>0:
		holdCounter-=delta*2
		holdCounter=max(0,holdCounter)
	SetHoldProgress(holdCounter/holdTime)
	if holdCounter>holdTime:
		holdCounter=0
		buttonPressed.emit()
	pass
	
	pass
