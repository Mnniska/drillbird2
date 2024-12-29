extends Node2D

#When getitng ores -> Check how much progress to state and SCALE the egg 
#up to target as one gets closer to state. When entering next state, switch sprite


#How much experience does each state require to go to next? 
@export var ExperienceRequirements:Array[int]
@export var StateTargetScales:Array[float]
@export var StateTargetSleepPositions:Array[float]
@export var Eggs:Array[Node2D]
@export var sleepPositions:Array[Node2D]
@onready var birdie=$BirdySleepPositions/birdySleep

var experienceGained:int=0

#0 is smallest, 1 small, 2 medium, 3 BIGGEST, 4 hatched 
var state:int=0

#Determines how close the egg is to its next state
var progress:float=0 

func Setup():
	pass

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	UpdateSize()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_2"):
		GlobalVariables.GivePlayerMoney(5)
		UpdateSize()
	
	pass

func SetBirdyVisible(visible:bool):
	if visible:
		birdie.show()
	else:
		birdie.hide()

func UpdateSize():
	experienceGained=GlobalVariables.totalExperienceGained
	
	var index=0
	var xp=experienceGained
	for n in ExperienceRequirements:
		xp-=ExperienceRequirements[index]
		if xp<0:
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
	
	"xpProgress= targetXP - abs(xp)
percentageProgress = xpProgress/targetXP"
	
	if state<ExperienceRequirements.size():
		
		var xpProgress= ExperienceRequirements[state]-abs(xp)
		var p:float= float(xpProgress)/float(ExperienceRequirements[state])
		var l = lerpf(1,StateTargetScales[state],p)	
		Eggs[state].scale= Vector2(l,l)
		
		var test=lerp(sleepPositions[state].position.y,sleepPositions[state+1].position.y,p)
		$BirdySleepPositions/birdySleep.position.y=test
		
	
	
