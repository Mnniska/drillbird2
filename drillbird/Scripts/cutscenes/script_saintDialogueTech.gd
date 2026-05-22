extends Node2D

@export var dialogueWhenTooLate:Array[String]
@export var dialogueWhenInTime:Array[String]

@export var dialogueWhenEggNotReady:Array[String]
@export var dialogueWhenEggReady:Array[String]

@export var greetingLineAfterFirstIntroduction:Array[String]


@onready var dialoguePlayer=$SaintDialoguePlayer

var hasGreetedPlayer:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dialoguePlayer.connect("aboutToPlay",UpdateDialogue)
	
	pass # Replace with function body.

func UpdateDialogue():
	
	var dialogueToPlay:Array[String]
	
	if GlobalVariables.currentDay <= GlobalVariables.daysBeforeDemonKillsEgg:
		
		if !hasGreetedPlayer:
		
			dialogueToPlay=dialogueWhenInTime
			hasGreetedPlayer=true

		else:
			dialogueToPlay.append(greetingLineAfterFirstIntroduction)
			#enum eggStates{NOTHING,GROWING,FINALFORM_NO_HEART,FINALFORM_HEART,FINALCUTSCENE}

		#If egg is ready 
		if GlobalVariables.eggState==2:
			
			for line in dialogueWhenEggReady:
				dialogueToPlay.append(line)
		 
		#if egg is not ready
		if GlobalVariables.eggState==1:
			for line in dialogueWhenEggNotReady:
				dialogueToPlay.append(line)
		
			#todo: Deal with if player has gotten the ordinary heart into the egg lol
		
	else:
		dialogueToPlay=dialogueWhenTooLate
	
	dialoguePlayer.linesToPlay=dialogueToPlay
	pass
