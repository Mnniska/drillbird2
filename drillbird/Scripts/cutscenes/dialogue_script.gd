extends Node2D
class_name dialogue_player

signal dialogueFinished
signal aboutToPlay

@onready var dialogueContainter=$VBoxContainer
@onready var text:RichTextLabel=$VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/text
@export var linesToPlay:Array[String]

@onready var continueSymbolText:RichTextLabel=$HBoxContainer/iconHolder/text_icon

#could also make a dialogue script and have an array of those if we want same dialogue script to alter betweeen diff dialogues

var dialogueHasPlayed:bool=false

var currentLineIndex:int=0

@export var onlyPlayOnce:bool=true

func _ready() -> void:
	hide()

func StartDialogue():
	aboutToPlay.emit()
	dialogueHasPlayed=true
	currentLineIndex=0
	show()
	
	ContinueDialogue()
	pass


func ContinueDialogue():
	var _text=tr(linesToPlay[currentLineIndex]) %str(GlobalVariables.daysBeforeDemonKillsEgg- GlobalVariables.currentDay)
	text.text=_text
	var boxSize=Vector2(min(220,_text.length()*6),0)
	$VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/text.custom_minimum_size= boxSize
	$HBoxContainer.position.x=boxSize.x/2

	
	continueSymbolText.text="[center]"+GlobalSymbolRegister.GetStringDecoded("(sing)",true)
	await GlobalVariables.playerSang
	
	if currentLineIndex<linesToPlay.size()-1:
		currentLineIndex+=1
		ContinueDialogue()
	else:
		hide()
		dialogueFinished.emit()
	pass


func _on_player_collider_body_entered(body: Node2D) -> void:
	
	if !dialogueHasPlayed or !onlyPlayOnce:
		StartDialogue()
	
	pass # Replace with function body.
