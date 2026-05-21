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
	
	if GlobalVariables.currentDay <= GlobalVariables.daysBeforeDemonKillsEgg:
		
		dialoguePlayer.linesToPlay=dialogueWhenInTime
	
	else:
		dialoguePlayer.linesToPlay=dialogueWhenTooLate
	
	pass
