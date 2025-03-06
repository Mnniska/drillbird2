extends Node2D

signal signal_pitch_dark()

#this will be given on load game, updated via the SHOP as well 
@export var bulbAmount:int

var lightBulbArray:Array[Sprite2D]

#Time variables
@export var time_TimerLength:int=135
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

#get player light
@onready var PlayerLight
@onready var LightSlider:Slider=$LightSliderParent/UI_LightSlider
@onready var DrillLightParticle=$LightSliderParent/Particle_DrillLight

var gamePaused:bool=true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Light.connect(upgradeChangeLight)
	GlobalVariables.lightSourceChange.connect(lightsourceChangeLight)
	GlobalVariables.signal_IsPlayerInMenuChanged.connect(GamePausedChange)
	#wait for game data to be loaded b4 accessing save data to set up light
	GlobalVariables.SetupComplete.connect(SetupLightFunctionality)
	GlobalVariables.PlayerIsDrillingTileChanged.connect(_on_player_signal_is_drilling_tile_changed)

func GamePausedChange(paused:bool):
	gamePaused=paused
	
	

func SetupLightFunctionality():
	PlayerLight=GlobalVariables.MainSceneReferenceConnector.playerDarkness
	if PlayerLight==null:
		push_error("Could not get player light, something is WRONG")
	
	
	time_Countdown=time_TimerLength

		#create lightbulbs depending on player upgrade lvl
	for n in GlobalVariables.upgradeLevel_light:
		var scene = load("res://Scenes/UI/lightbulb.tscn") 
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
	pass

func UpdateLightbulbLocations():
	var lightSliderOffset:int=14
	var bulbOffset=8
	
	var sliderlocation:int=0
	var startingOffset:int=((lightBulbArray.size()*bulbOffset)+lightSliderOffset)/2

	
	var index:int =0 
	
	for n in range(lightBulbArray.size(),0,-1):
		var lOffset:int=0
		if lightBulbArray[n-1].active:
			sliderlocation+=bulbOffset
		else:
			lOffset=lightSliderOffset
		
		lightBulbArray[n-1].position.x=-startingOffset+ (bulbOffset*index) + lOffset
		lightBulbArray[n-1].position.y=0
		index+=1

	$LightSliderParent.position.x=-startingOffset+sliderlocation-3

func GetNextLightbulb():
	
	var foundBulb:bool=false
	
	
	for n in range(0,lightBulbArray.size(),1):
	
			break
	
	for n in lightBulbArray:
		if n.active:
			n.SetActive(false)
			time_Countdown=time_TimerLength
			foundBulb=true
			
			break
	
	for n in lightBulbArray:
		if n.active:
			UpdateLightbulbLocations()
			return true
	
	darknessClose=true
	UpdateLightbulbLocations()
	return foundBulb

func SetLightPosition():
	var offset:Vector2=Vector2(0,0)
	var size=12
	var progress = size*(LightSlider.value/100)
	DrillLightParticle.position=offset+Vector2(progress,0)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	if HUD.sceneState==HUD.sceneStates.CREDITS or gamePaused or GlobalVariables.InitialSetup:
		return
	
	handleInputs()
	if playerIsLit:
		return
		
	if time_Countdown>0:
		var multiplier:float=1
		if playerIsDrillingTile:
			multiplier=time_DrillMultiplier
			SetLightPosition()
			$LightSliderParent/Particle_DrillLight.emitting=true
		else:
			$LightSliderParent/Particle_DrillLight.emitting=false
		time_Countdown-=delta*multiplier
		

		
		internal_upd_counter+=1
		if internal_upd_counter>internal_upd_interval:
			internal_upd_counter=0
			
			var progress=float(time_Countdown/time_TimerLength)
			
			#The light sliders last 10% is hidden behind the border, so I am artificially having the light bar end at 10 instead of 0
			var min=0
			var max = LightSlider.max_value
			var value= (max-min)*progress+min
			LightSlider.value=value
			
			if darknessClose:
				PlayerLight.SetLight(progress)
			
	else:
		#will only set itself to be out of light once
		if !outOfLight: 
			#returns false if there are no more lightbulbs. Here to not call every frame
			if !GetNextLightbulb():
				signal_pitch_dark.emit()
				outOfLight=true
				$LightSliderParent/Particle_DrillLight.emitting=false
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
	UpdateLightbulbLocations()

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
	var scene = load("res://Scenes/UI/lightbulb.tscn") 
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
