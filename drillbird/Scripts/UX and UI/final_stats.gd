extends Node2D
@onready var StatsParent=$STATS
@onready var statsMessage=$STATS/stats
@onready var SebsMessage=$"Sebs message"
@onready var choiceMessage=$choice
@onready var white=$white_background
var textIsReady:bool=false
enum states{inactive,info,seb,choice}
var state:states=states.inactive
signal textFinishedShowing()
signal statsFinished(bool)


var textshown:int=0
@export var typewritePause:float=0.04

var finalChoiceIsToErase:bool=true

@export var finalchoicetext_erase:String
@export var finalchoicetext_goback:String

func _ready() -> void:
	hide()
	StatsParent.hide()
	SebsMessage.hide()
	choiceMessage.hide()

func FadeFromWhite():
	white.show()
	var alpha=1
	while alpha>0:
		
		white.self_modulate.a=alpha
		await get_tree().create_timer(0.005).timeout
		alpha-=0.005
	white.hide()

func DisplayStats():
	hidestuff()
	state=states.info
	statsMessage.text=ConstructStatsString()
	statsMessage.visible_characters=0
	StatsParent.show()
	await get_tree().create_timer(0.5).timeout
	TypewriteText(statsMessage)
	
func hidestuff():
	SebsMessage.hide()
	StatsParent.hide()
	choiceMessage.hide()

func DisplaySebsMessage():
	hidestuff()
	show()
	FadeFromWhite()
	await get_tree().create_timer(2).timeout
	state=states.seb
	StatsParent.hide()
	SebsMessage.show()
	TypewriteText(SebsMessage)

func DisplayFinalChoice():
	hidestuff()
	state=states.choice
	SebsMessage.hide()
	choiceMessage.show()
	TypewriteText(choiceMessage)
	pass

func _process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("debug_tab"):
		DisplaySebsMessage()
	
	if Input.is_action_just_pressed("jump"):
		if !textIsReady:
			textIsReady=true
		else:
			if state==states.info:
				DisplayFinalChoice()
			elif state==states.seb:
				DisplayStats()
			elif state==states.choice:
				statsFinished.emit(finalChoiceIsToErase)

	
	if state==states.choice:
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
			finalChoiceIsToErase=!finalChoiceIsToErase
			UpdateFinalChoiceText()

func UpdateFinalChoiceText():
	
	if finalChoiceIsToErase:
		choiceMessage.text=finalchoicetext_erase
	else:
		choiceMessage.text=finalchoicetext_goback
	
	pass

func TypewriteText(label:RichTextLabel):
	textIsReady=false
	textshown=0
	label.visible_characters=0
	var skip:bool=false
	while label.visible_characters<label.text.length()-1:
		textshown+=1
		label.visible_characters=textshown
		if label.text[textshown]=="[": #ensures there's no pausing for hidden bbcode stuff
			skip=true
			
		if skip:
			if label.text[textshown]=="]":
				skip=false
		else:
			
			if !skip:
				SoundManager.PlaySoundAtLocation($bg.global_position,abstract_SoundEffectSetting.SoundEffectEnum.TYPEWRITER_CLICK)
			await get_tree().create_timer(typewritePause).timeout
			
			
		if textIsReady:
			label.visible_characters=label.text.length()
			break
	textIsReady=true
	textFinishedShowing.emit()
	
	pass 
	
func ConstructStatsString()->String:
	var text:String
	text+="Days taken to hatch:   " 
	text+="[color=orange]"+ str(GlobalVariables.currentDay)+"[/color]"+"[p] [/p]"
	text+="[center][wave][rainbow]Continue"
	
	"Time taken: 2 h, 10 min, 5 secs and 44 ms

Ores collected: 102/123


[center][wave][rainbow]Continue"
	
	
	
	
	return text
	
	
	pass
