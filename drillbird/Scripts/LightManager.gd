extends Node2D

signal signal_pitch_dark()

#this will be given on load game, updated via the SHOP as well 
@export var bulbAmount:int

var lightBulbArray:Array[light_bulb]

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
var currentLightbulb:light_bulb

#get player light
@onready var PlayerLight
@onready var LightSlider:Slider=$LightSliderParent/UI_LightSlider
@onready var DrillLightParticle=$LightSliderParent/Particle_DrillLight


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Light.connect(upgradeChangeLight)
	GlobalVariables.lightSourceChange.connect(lightsourceChangeLight)
	
	#wait for game data to be loaded b4 accessing save data to set up light
	GlobalVariables.SetupComplete.connect(SetupLightFunctionality)
	GlobalVariables.PlayerIsDrillingTileChanged.connect(_on_player_signal_is_drilling_tile_changed)
	
func SetupLightFunctionality():
	PlayerLight=GlobalVariables.MainSceneReferenceConnector.playerDarkness
	if PlayerLight==null:
		push_error("Could not get player light, something is WRONG")
	
	
	time_Countdown=time_TimerLength
	GetNextLightbulb()

		#create lightbulbs depending on player upgrade lvl
	for n in GlobalVariables.upgradeLevel_light:
		var scene = load("res://Scenes/UI/lightbulb.tscn") 
		var node:light_bulb = scene.instantiate()
		node.SetSliderProgress(1)
		lightBulbArray.append(node)
		var offset= Vector2(0,-4)
		
		node.transform.origin = offset
		add_child(node)
	UpdateLightbulbLocations()
	UpdatePlayerLightStatus()

	#First Setup stuff - might move to its own function
	PlayerLight.SetLight(1)
	SetSliderValue(1)
	pass

func UpdateLightbulbLocations():
	var center:Node2D = %LightBulbCenter
	
	var unevenOffset:float=0
	var bulbOffset=8
	var spriteOffset:Vector2=Vector2(-8,-8)
	
	if lightBulbArray.size()%2==0:
		unevenOffset=-8
	
	var startingOffset:float=unevenOffset+((lightBulbArray.size()*bulbOffset))/2

	
	for n in range(lightBulbArray.size(),0,-1):
		lightBulbArray[n-1].position=center.position+spriteOffset+Vector2(-startingOffset+(bulbOffset*n),0)
		
	

func GetNextLightbulb():
	
	if !GetCurrentLightbulb():
		darknessClose=true
		return false
	else:
		currentLightbulb=GetCurrentLightbulb()
		UpdateLightbulbLocations()
		
		return true
	

func SetDrillParticlePosition():
	
	if darknessClose:
		var length=6*16+12
		var offset:Vector2=Vector2(-length/2+8,0)
		
		var progress=float(time_Countdown/time_TimerLength)*length
		DrillLightParticle.position=offset+Vector2(progress,0)
	else:
		if currentLightbulb!=null:
			DrillLightParticle.position=currentLightbulb.position
			#test hehe
	
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if HUD.sceneState==HUD.sceneStates.CREDITS:
		return
	
	if playerIsLit:
		return
		
	if time_Countdown>0:
		var multiplier:float=1
		if playerIsDrillingTile:
			multiplier=time_DrillMultiplier
			SetDrillParticlePosition()
			$LightSliderParent/Particle_DrillLight.emitting=true
		else:
			$LightSliderParent/Particle_DrillLight.emitting=false
		time_Countdown-=delta*multiplier
		

		
		internal_upd_counter+=1
		if internal_upd_counter>internal_upd_interval:
			internal_upd_counter=0
			
			var progress=float(time_Countdown/time_TimerLength)
			
			SetSliderValue(progress)
			
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
	SetSliderValue(0)

	UpdatePlayerLightStatus()

func SetSliderValue(_progress:float):
	
	if GetCurrentLightbulb():
		GetCurrentLightbulb().SetSliderProgress(_progress)
	else:
		var min=4
		var max=100
		
		var value=min+_progress*(max-min)
		LightSlider.value=value

func GetCurrentLightbulb()->light_bulb:
	for bulb in lightBulbArray:
		if bulb.hasLight:
			return bulb
	
	return null

func RefillLight():
	

	for n in lightBulbArray:
		n.SetSliderProgress(1)
	
	time_Countdown=time_TimerLength
	SetSliderValue(1)
	darknessClose = GlobalVariables.upgradeLevel_light==0
	PlayerLight.SetLight(1)
	outOfLight=false
	UpdatePlayerLightStatus()
	UpdateLightbulbLocations()



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
	var node:light_bulb = scene.instantiate()
	var offset= Vector2(0,-4)
	lightBulbArray.append(node)
	add_child(node)
	node.position=offset
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
