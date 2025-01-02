extends Node2D

signal signal_pitch_dark()

#this will be given on load game, updated via the SHOP as well 
@export var bulbAmount:int

var lightBulbArray:Array[Sprite2D]

#Time variables
@export var time_TimerLength:int=3
@export var time_DrillMultiplier:float=2
#todo: Figure out if this is how you wanna do time
var time_Countdown:float
var darknessClose:bool=false
var maxSize:int=75
var minSize:int=1
var internal_upd_interval:int=60
var internal_upd_counter:int=0
var playerIsLit:bool=false
var outOfLight:bool=false
var playerIsDrillingTile:bool=false

@onready var PlayerLight=$"../../PlayerDarkness"
@onready var LightSlider:Slider=$UI_LightSlider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Light.connect(upgradeChangeLight)
	GlobalVariables.lightSourceChange.connect(lightsourceChangeLight)
	
	time_Countdown=time_TimerLength
	
	#create lightbulbs depending on player upgrade lvl
	for n in GlobalVariables.upgradeLevel_light:
		var scene = load("res://Scenes/lightbulb.tscn") 
		var node = scene.instantiate()
		node.SetActive(true)
		lightBulbArray.append(node)
		var offset= Vector2(0,-4)
		
		node.transform.origin = offset
		add_child(node)
	UpdateLightbulbLocations()
	if GlobalVariables.upgradeLevel_light==0:
		darknessClose=true
	UpdatePlayerLightStatus()

	#First Setup stuff - might move to its own function
	PlayerLight.SetLight(1)
	LightSlider.value=100



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
	
	var foundBulb:bool=false
	for n in lightBulbArray:
		if n.active:
			n.SetActive(false)
			time_Countdown=time_TimerLength
			foundBulb=true
			break
	
	for n in lightBulbArray:
		if n.active:
			return true
	
	darknessClose=true
	return foundBulb

func SetLightPosition():
	var offset:Vector2=Vector2(-40,5)
	var size=76
	var progress = size*(LightSlider.value/100)
	$Particle_DrillLight.position=offset+Vector2(progress,0)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	handleInputs()
	if playerIsLit:
		return
		
	if time_Countdown>0:
		var multiplier:float=1
		if playerIsDrillingTile:
			multiplier=time_DrillMultiplier
			SetLightPosition()
			$Particle_DrillLight.emitting=true
		else:
			$Particle_DrillLight.emitting=false
		time_Countdown-=delta*multiplier
		

		
		internal_upd_counter+=1
		if internal_upd_counter>internal_upd_interval:
			internal_upd_counter=0
			
			var progress=float(time_Countdown/time_TimerLength)
			LightSlider.value=progress*100
			
			if darknessClose:
				PlayerLight.SetLight(progress)
			
	else:
		#will only set itself to be out of light once
		if !outOfLight: 
			#returns false if there are no more lightbulbs. Here to not call every frame
			if !GetNextLightbulb():
				signal_pitch_dark.emit()
				outOfLight=true
				$Particle_DrillLight.emitting=false
				UpdatePlayerLightStatus()
			pass
	pass
	
func DepleteLight():
	
	time_Countdown=0
	darknessClose=true
	for n in lightBulbArray:
		n.SetActive(false)
	PlayerLight.SetLight(0)
	LightSlider.value=0

	UpdatePlayerLightStatus()
	
func RefillLight():
	

	for n in lightBulbArray:
		n.SetActive(true)
	
	time_Countdown=time_TimerLength
	LightSlider.value=100
	darknessClose = GlobalVariables.upgradeLevel_light==0
	PlayerLight.SetLight(1)
	outOfLight=false
	UpdatePlayerLightStatus()

func handleInputs():
	
	pass # Replace with function body.

func UpdatePlayerLightStatus():
	if GlobalVariables.amountOfLightsourcesPlayerIsIn>0:
		playerIsLit=true
		GlobalVariables.playerLightStatus=GlobalVariables.playerLightStatusEnum.LIT_EXTERNALLY
	else:
		playerIsLit= false
		
		if outOfLight:
			GlobalVariables.playerLightStatus=GlobalVariables.playerLightStatusEnum.DARK
		else:
			GlobalVariables.playerLightStatus=GlobalVariables.playerLightStatusEnum.LIT_BYPLAYER
	

		
	

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
	if !GlobalVariables.InitialSetup:
		AddLightbulbRequest()
	pass

func lightsourceChangeLight():
	UpdatePlayerLightStatus()


func _on_player_signal_is_drilling_tile_changed(value: bool) -> void:
	playerIsDrillingTile=value
	
	pass # Replace with function body.
