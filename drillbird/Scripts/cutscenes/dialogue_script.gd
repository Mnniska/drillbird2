extends Node2D

signal dialogueFinished

@onready var dialogueContainter=$VBoxContainer
@onready var text:RichTextLabel=$VBoxContainer/PanelContainer/MarginContainer/text
@export var linesToPlay:Array[String]

@onready var continueSymbolText:RichTextLabel=$HBoxContainer/iconHolder/text_icon
#could also make a dialogue script and have an array of those if we want same dialogue script to alter betweeen diff dialogues

var dialogueHasPlayed:bool=false

var currentLineIndex:int=0

func _ready() -> void:
	hide()

func StartDialogue():
	dialogueHasPlayed=true
	currentLineIndex=0
	show()
	
	ContinueDialogue()
	pass


func ContinueDialogue():
	text.text=tr(linesToPlay[currentLineIndex])
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
	
	if !dialogueHasPlayed:
		StartDialogue()
	
	pass # Replace with function body.
