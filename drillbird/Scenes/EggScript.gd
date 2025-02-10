extends Node2D

#When getitng ores -> Check how much progress to state and SCALE the egg 
#up to target as one gets closer to state. When entering next state, switch sprite


#How much experience does each state require to go to next? 
@export var ExperienceRequirements:Array[int]
@export var StateTargetScales:Array[float]
@export var Eggs:Array[Node2D]
@export var sleepPositions:Array[Node2D]
@onready var birdie=$BirdySleepPositions/birdySleep

var isLerping:bool=false
var oldXP:int=0
@export var lerptime:float=1

var experienceGained:int=0

#0 is smallest, 1 small, 2 medium, 3 BIGGEST, 4 hatched 
var state:int=0

#Determines how close the egg is to its next state
var progress:float=0 

func Setup():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GlobalVariables.SetupComplete.connect(UpdateEggSizeAtStartup)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.


func SetBirdyVisible(visible:bool):
	if visible:
		birdie.show()
	else:
		birdie.hide()

func UpdateEggSizeAtStartup():
	UpdateSizeBasedOnSaveData(false)
	
func UpdateSizeBasedOnSaveData(shouldLerp:bool):
	
	if shouldLerp && !isLerping:
		LerpToCurrentXP()
		
	else:
		UpdateSize(GlobalVariables.totalExperienceGained)

func LerpToCurrentXP():
	isLerping=true
	oldXP=experienceGained
	experienceGained=GlobalVariables.totalExperienceGained
	
	var distance=experienceGained-oldXP
	
	while oldXP<experienceGained:
		oldXP+=1
		UpdateSize(oldXP)
		await get_tree().create_timer(lerptime/distance)
	
	isLerping=false
	
	pass

func UpdateSize(experience:int):
	
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
	
	
