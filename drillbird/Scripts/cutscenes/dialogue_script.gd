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

@onready var continueSymbolParent:HBoxContainer=$HBoxContainer
@onready var continueSymbolText:RichTextLabel=$HBoxContainer/iconHolder/text_icon

@export var saintTalking:bool=false

@export var maxBoxWidth:int=220
@export var startViaCollider:bool=true

#could also make a dialogue script and have an array of those if we want same dialogue script to alter betweeen diff dialogues

var dialogueHasPlayed:bool=false

var currentLineIndex:int=0
var waitingForPlayer:bool=false


@export var onlyPlayOnce:bool=true

@export var timeBeforeShowingButton:float=6
var counterBeforeShowingButton:float=0

func _ready() -> void:
	SetupDialogueBoxSettings(saintTalking)
	hide()
	

func SetupDialogueBoxSettings(isSaint:bool):
	
	
	if isSaint:
		$tail.position=$tailLeftPosition.position
		$tail.flip_h=true
		$VBoxContainer/HBoxContainer.alignment=0
		maxBoxWidth=150
	else:
		$tail.position=$tailCenterPosition.position
		$tail.flip_h=false
		$VBoxContainer/HBoxContainer.alignment=1
		maxBoxWidth=220
	
	

func StartDialogue():
	aboutToPlay.emit()
	dialogueHasPlayed=true
	currentLineIndex=0
	show()
	
	ContinueDialogue()



func _process(delta: float) -> void:

	counterBeforeShowingButton+=delta
	if counterBeforeShowingButton>timeBeforeShowingButton:
		SetShowContinueButton(true)


func SetShowContinueButton(show:bool):
	if show and !currentLineIsOnlyAnim:
		continueSymbolParent.show()
	else:
		continueSymbolParent.hide()
		
var currentLineIsOnlyAnim:bool=false

func ContinueDialogue():
	
	var _text=null
	if linesToPlay[currentLineIndex].lineToPlay!="":
		_text=tr(linesToPlay[currentLineIndex].lineToPlay) %str(GlobalVariables.daysBeforeDemonKillsEgg- GlobalVariables.currentDay)
		text.text=_text
		currentLineIsOnlyAnim=false
	else:
		currentLineIsOnlyAnim=true
		text.text=""
	
	if currentLineIndex==0 and !currentLineIsOnlyAnim:
		SetShowContinueButton(true)
	else:
		SetShowContinueButton(false)
	counterBeforeShowingButton=0
	

	
	
	if currentLineIsOnlyAnim: #leaving a text empty allows animator to play only animations without dialogues
		$VBoxContainer.hide()
		$tail.hide()
	else:
		$VBoxContainer.show()
		$tail.show()
		#maxbozxwidth changes depending on if saint or demon is talking
		var boxSize=Vector2(min(maxBoxWidth,_text.length()*6),0)
	
	
		#Set continue button to right side if dialogue box, it changes size depending on spacing
		$VBoxContainer/HBoxContainer/PanelContainer/MarginContainer/text.custom_minimum_size= boxSize
	
		if saintTalking:
			$HBoxContainer.position.x=$tail.position.x + boxSize.x - 10
		else:
			$HBoxContainer.position.x=boxSize.x/2
	
	if linesToPlay[currentLineIndex].soundToPlay:
		soundPlayer.stream=linesToPlay[currentLineIndex].soundToPlay
		soundPlayer.play()
	
	continueSymbolText.text="[center]"+GlobalSymbolRegister.GetStringDecoded("(sing)",true)
	
	#Animation stuff 
	if linesToPlay[currentLineIndex].animToPlay!=null and animatorToAnimate!=null:
		animatorToAnimate.animation=linesToPlay[currentLineIndex].animToPlay
		animatorToAnimate.play()
	
	#sound
	if linesToPlay[currentLineIndex].soundToPlay!=null:
		pass
	
	if !currentLineIsOnlyAnim:
		await GlobalVariables.playerSang
	else:
		await animatorToAnimate.animation_finished
	
	if currentLineIndex<linesToPlay.size()-1:
		currentLineIndex+=1
		ContinueDialogue()
	else:
		hide()
		dialogueFinished.emit()
	pass
	
	



func _on_player_collider_body_entered(body: Node2D) -> void:
	
	if !startViaCollider:
		return
	
	if !dialogueHasPlayed or !onlyPlayOnce:
		StartDialogue()
	
	pass # Replace with function body.
