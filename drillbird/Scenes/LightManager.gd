extends Node2D

#this will be given on load game, updated via the SHOP as well 
@export var bulbAmount:int

@export var lightUpgrade:int =2
var lightBulbArray:Array[Sprite2D]

#Time variables
@export var time_TimerLength:int=30
#todo: Figure out if this is how you wanna do time
var time_Countdown:float
var darknessClose:bool=false
var maxSize:int=75
var minSize:int=1
var internal_upd_interval:int=60
var internal_upd_counter:int=0

@onready var PlayerLight=$"../../Player/PlayerDarkness"
@onready var LightSlider=$UI_LightSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Light.connect(upgradeChangeLight)
	
	time_Countdown=time_TimerLength
	
	for n in lightUpgrade:
		var scene = load("res://Scenes/lightbulb.tscn") 
		var node = scene.instantiate()
		node.SetActive(true)
		lightBulbArray.append(node)
		
		var offset= Vector2(0,-4)
		
		node.transform.origin = offset
		add_child(node)
	UpdateLightbulbLocations()

func UpdateLightbulbLocations():
	var offset:int=0
	offset=(floor(lightBulbArray.size())/2)*8
	offset-=4 #accounts for the pivot not being at the side
	if(lightBulbArray.size()%2>0):
		offset+=4
		pass
	var index:int =0 
	for n in lightBulbArray:
		n.position.x=self.position.x+ offset-(8*index)
		index+=1
	
func GetNextLightbulb():
	for n in lightBulbArray:
		if n.active:
			n.SetActive(false)
			time_Countdown=time_TimerLength
			break
	
	for n in lightBulbArray:
		if n.active:
			return true
	darknessClose=true

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
			
			if darknessClose:
				PlayerLight.SetLight(progress)
			
	else:
		GetNextLightbulb()
	pass
	
func RefillLight():
	for n in lightBulbArray:
		n.SetActive(true)
		time_Countdown=time_TimerLength
		darknessClose=false
		PlayerLight.SetLight(1)

func handleInputs():

	if Input.is_action_just_pressed('addLight'):
		RefillLight()

		pass

	if Input.is_action_just_pressed('removeLight'):
		pass
	
	pass # Replace with function body.

func AddLightbulbRequest():
	var scene = load("res://Scenes/lightbulb.tscn") 
	var node = scene.instantiate()
	var offset= Vector2(0,-4)
	lightBulbArray.append(node)
	node.transform.origin =  offset
	add_child(node)
	RefillLight()
	UpdateLightbulbLocations()

func upgradeChangeLight():
	AddLightbulbRequest()
	pass
