extends Node2D

#this will be given on load game, updated via the SHOP as well 
@export var bulbAmount:int

#Time variables
@export var time_TimerLength:int=10
var time_Countdown:float



var maxSize:int=75
var minSize:int=1
var internal_upd_interval:int=60
var internal_upd_counter:int=0

@onready var PlayerLight=$"../../Player/PlayerDarkness"
@onready var LightSlider=$UI_LightSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	time_Countdown=time_TimerLength
	pass # Replace with function body.
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleInputs()
	if time_Countdown>0:
		time_Countdown-=delta

		internal_upd_counter+=1
		if internal_upd_counter>internal_upd_interval:
			internal_upd_counter=0
			var progress=float(time_Countdown/time_TimerLength)
			LightSlider.value=progress*100
			PlayerLight.SetLight(progress)
			
		
	pass
	
func handleInputs():

	if Input.is_action_just_pressed('addLight'):
		time_Countdown=time_TimerLength
		pass

	if Input.is_action_just_pressed('removeLight'):
		pass
