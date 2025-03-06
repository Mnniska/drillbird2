extends Node2D
class_name egg_script

signal FinalHeartPlaced
#When getitng ores -> Check how much progress to state and SCALE the egg 
#up to target as one gets closer to state. When entering next state, switch sprite

enum eggStates{NOTHING,GROWING,FINALFORM_NO_HEART,FINALFORM_HEART,FINALCUTSCENE}
var eggState=eggStates.NOTHING

#How much experience does each state require to go to next? 
@export var ExperienceRequirements:Array[int]
@export var StateTargetScales:Array[float]
@export var Eggs:Array[Node2D]
@export var sleepPositions:Array[Node2D]
@onready var birdie=$BirdySleepPositions/birdySleep
@onready var finalFormEgg:egg_final_form=$Egg_FinalForm
@onready var nest_front=$nest_front
@onready var nest_back=$nest_back

var shakeTimer:float=0
var originalPos:Vector2=self.position
var shaking:bool=false

signal signal_OneShotIsBiggestSize
var isBiggestSize:bool=false:
	get: return isBiggestSize
	set(value):
		if value && !isBiggestSize:
			signal_OneShotIsBiggestSize.emit()
		isBiggestSize=value

var isLerping:bool=false
var oldXP:int=0
@export var lerptime:float=1
var lerpTimeCounter:float=0

var experienceGained:int=0

#0 is smallest, 1 small, 2 medium, 3 BIGGEST, 4 hatched 
var state:int=0
#Determines how close the egg is to its next state
var progress:float=0 

func Setup():
	
	eggState=GlobalVariables.eggState
	SetEggState(eggState)

	
	#TODO: Egg state should initially be EMPTY and change to growing after the egg spawning cutscene
	if eggState==eggStates.GROWING:
		UpdateSizeBasedOnSaveData()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(Setup)	


	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func SetNestVisible(visible:bool):
	if visible:
		nest_front.show()
		nest_back.show()
	else:
		nest_front.hide()
		nest_back.hide()

func SetEggState(_state:eggStates):
	eggState=_state
	
	SetNestVisible(!eggState==eggStates.NOTHING)
	
	
	match eggState:
		eggStates.NOTHING:
			hideEggs()
			finalFormEgg.SetState(finalFormEgg.finalFormStates.FINAL_INACTIVE)

			pass
		eggStates.GROWING:
			show()
			finalFormEgg.SetState(finalFormEgg.finalFormStates.FINAL_INACTIVE)
			pass
		eggStates.FINALFORM_NO_HEART:
			hideEggs()
			finalFormEgg.SetState(finalFormEgg.finalFormStates.FINAL_HEARTLESS)
			pass
		eggStates.FINALFORM_HEART:
			hideEggs()
			finalFormEgg.SetState(finalFormEgg.finalFormStates.FINAL_HEART)
			pass
		eggStates.FINALCUTSCENE:
			#THIS WILL likely never be saved, so won't be used. but who knows :) 
			$nest_front.hide()
			hideEggs()
			finalFormEgg.SetState(finalFormEgg.finalFormStates.FINAL_HATCHING)
			pass
			
	GlobalVariables.eggState=eggState

func TransitionToFinalFormWithHeart():
	SetEggState(eggStates.FINALFORM_HEART)	
	finalFormEgg.RecieveHeartCutscene()



func hideEggs():
	for egg in Eggs:
		egg.hide()

func SetBirdyVisible(visible:bool):
	if visible:
		birdie.show()
	else:
		birdie.hide()
	
	
func UpdateSizeBasedOnSaveData():
	
	UpdateSize(GlobalVariables.totalEGGsperienceGained)
	
	

func GetIsEggMaxedOut():
	var xp=GlobalVariables.totalEGGsperienceGained
	for n in ExperienceRequirements:
		xp-=n
	
	return xp>0

func UpdateSize(experience:int):

	if eggState!=eggStates.GROWING:
		shakeTimer+=0.4
		shaking=true
		return
	
	oldXP=experience
	var index=0
	var xp=experience
	
	for n in ExperienceRequirements:
		xp-=ExperienceRequirements[index]
		if xp < 0:
			break
			
		index+=1
		#index will become 3 if player has the biggest upgrade
		pass
	
	state=index
	
	var y=0
	for n in Eggs:
		if y==state:
			Eggs[y].show()
		else:
			Eggs[y].hide()
		y+=1
	pass
	
	if state<ExperienceRequirements.size():
		
		var xpProgress= ExperienceRequirements[state]-abs(xp)
		var progress:float= float(xpProgress)/float(ExperienceRequirements[state])
		var l = lerpf(StateTargetScales[state],1,progress)	
		Eggs[state].scale= Vector2(l,l)
		
		var test=lerp(sleepPositions[state].position.y,sleepPositions[state+1].position.y,progress)
		$BirdySleepPositions/birdySleep.position.y=test
	
	if GetIsEggMaxedOut():
		SetEggState(eggStates.FINALFORM_NO_HEART)
		finalFormEgg.TransitionToFinalForm()
	
func _process(delta: float) -> void:

	if shaking:
		position=originalPos+Vector2(randf_range(-2,2),0)
		shakeTimer-=delta
		if shakeTimer<0:
			shaking=false
			position=originalPos
