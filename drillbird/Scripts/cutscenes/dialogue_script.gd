extends Node2D
class_name dialogue_player

signal dialogueFinished
signal aboutToPlay

@onready var dialogueContainter=$VBoxContainer
@onready var text:RichTextLabel=$VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/text
@export var linesToPlayOld:Array[String]
@onready var soundPlayer:AudioStreamPlayer2D=$sound
@export var animatorToAnimate:AnimatedSprite2D

@export var linesToPlay:Array[abs_dialogue_line]

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
	var _text=tr(linesToPlay[currentLineIndex].lineToPlay) %str(GlobalVariables.daysBeforeDemonKillsEgg- GlobalVariables.currentDay)
	text.text=_text
	var boxSize=Vector2(min(220,_text.length()*6),0)
	
	#Set continue button to right side if dialogue box, it changes size depending on spacing
	$VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/text.custom_minimum_size= boxSize
	$HBoxContainer.position.x=boxSize.x/2
	
	if linesToPlay[currentLineIndex].soundToPlay:
		soundPlayer.stream=linesToPlay[currentLineIndex].soundToPlay
		soundPlayer.play()
	
	continueSymbolText.text="[center]"+GlobalSymbolRegister.GetStringDecoded("(sing)",true)
	
	#Animation stuff 
	if linesToPlay[currentLineIndex].animToPlay!=null and animatorToAnimate!=null:
		animatorToAnimate.animation=linesToPlay[currentLineIndex].animToPlay
	
	#sound
	if linesToPlay[currentLineIndex].soundToPlay!=null:
		pass
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
