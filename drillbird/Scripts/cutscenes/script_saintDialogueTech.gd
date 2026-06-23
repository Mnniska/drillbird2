extends Node2D


@export var dialogueWhenTooLate:Array[abs_dialogue_line]
@export var dialogueWhenInTime:Array[abs_dialogue_line]

@export var dialogueWhenEggNotReady:Array[abs_dialogue_line]
@export var dialogueWhenEggReady:Array[abs_dialogue_line]

@export var greetingLineAfterFirstIntroduction:Array[abs_dialogue_line]


@export var soulOre:abstract_ore

@onready var dialoguePlayer=$SaintDialoguePlayer

var hasGreetedPlayer:bool=false
enum saintStates{saint_dead,saint_alive_egg_not_ready,saint_alive_egg_ready}
var saintState:saintStates

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialoguePlayer.connect("aboutToPlay",UpdateDialogue)
	
	await GlobalVariables.SetupComplete
	
	pass # Replace with function body.

func UpdateDialogue():
	
	var dialogueToPlay:Array[abs_dialogue_line]
	
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
		
	else:
		dialogueToPlay=dialogueWhenTooLate
		saintState=saintStates.saint_dead
	
	dialoguePlayer.linesToPlay=dialogueToPlay
	dialoguePlayer.dialogueFinished.connect(dialogueFinished)
	
func dialogueFinished():
	
	if saintState==saintStates.saint_alive_egg_ready:
		SpawnSaintOre()
	
	
	
	pass

func SpawnSaintOre():
	var oreSpawner:ore_manager=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	var location = $oreSpawnLocation.global_position
	oreSpawner.SpawnOreAtLocation(location,soulOre,Vector2(0,0),true,false)
