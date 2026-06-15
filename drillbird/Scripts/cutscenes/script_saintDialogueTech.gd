extends Node2D

@export var dialogueWhenTooLate:Array[String]
@export var dialogueWhenInTime:Array[String]

@export var dialogueWhenEggNotReady:Array[String]
@export var dialogueWhenEggReady:Array[String]

@export var greetingLineAfterFirstIntroduction:Array[String]
@export var soulOre:abstract_ore

@onready var dialoguePlayer=$SaintDialoguePlayer

var hasGreetedPlayer:bool=false
enum saintStates{saint_dead,saint_alive_egg_not_ready,saint_alive_egg_ready}
var saintState:saintStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialoguePlayer.connect("aboutToPlay",UpdateDialogue)
	
	await GlobalVariables.SetupComplete
	SpawnSaintOre()
	pass # Replace with function body.

func UpdateDialogue():
	
	var dialogueToPlay:Array[String]
	
	if GlobalVariables.currentDay <= GlobalVariables.daysBeforeDemonKillsEgg: #if saint isn't dead yet
		
		if !hasGreetedPlayer:
		
			dialogueToPlay=dialogueWhenInTime
			hasGreetedPlayer=true
			saintState=saintStates.saint_alive_egg_not_ready
		else:
			dialogueToPlay.append(greetingLineAfterFirstIntroduction)
			#enum eggStates{NOTHING,GROWING,FINALFORM_NO_HEART,FINALFORM_HEART,FINALCUTSCENE}

		#If egg is ready 
		if GlobalVariables.eggState==2:
			saintState=saintStates.saint_alive_egg_ready
			for line in dialogueWhenEggReady:
				dialogueToPlay.append(line)
				
		 
		#if egg is not ready
		if GlobalVariables.eggState==1:
			for line in dialogueWhenEggNotReady:
				dialogueToPlay.append(line)
		

		#TODO: Make saint react to if the player has already inserted the heart? lol
		
			#todo: Deal with if player has gotten the ordinary heart into the egg lol
		
		#Pitch for saint and demon dialogue tech:
		#Create POSES with looping 3 frame anims that sell them
		#Via dialogue, can select which POSE to play. Game removes the [POSE] text from the dialogue line
		#Characters instantly switch to new pose when told.
		#Could add a delay if needed but not required
		
		#but does dialogue fit in with the poses? the box is pretty big! 
		#let's create some mockups :) 
		
		#TODO: Spawn a SAINT HEART after the dialogue if valid
		#Saint heart.. 
		#works like a normal heart
		#Could maybe have more stuff chase player if they have it - or imbed the ghost with goo power lol 
		
	else:
		dialogueToPlay=dialogueWhenTooLate
		saintState=saintStates.saint_dead
	
	dialoguePlayer.linesToPlay=dialogueToPlay
	dialoguePlayer.dialogueFinished.connect(dialogueFinished)
	pass

func dialogueFinished():
	
	if saintState==saintStates.saint_alive_egg_ready:
		SpawnSaintOre()
	
	
	
	pass

func SpawnSaintOre():
	var oreSpawner:ore_manager=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	var location = $oreSpawnLocation.global_position
	oreSpawner.SpawnOreAtLocation(location,soulOre,Vector2(0,0),true,false)
