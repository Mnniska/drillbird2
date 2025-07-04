extends Node2D
class_name menu_option

signal button_pressed(option:menu_option)
signal sliderValueChanged(menuName:String,progress:float)

@export var optionName:String
@export var localizationID:String
@export var isAction:bool=true
@export var isToggle:bool=false
@export var options:Array[menu_option]

@export var RequireExtraConfirmation:bool=false
var hasclickedonce:bool=false
@export var extraConfirmzationMessage:RichTextLabel
@export var extraConfirmationMessageLocalizationID:String

@onready var text=$RichTextLabel
@onready var sliderKnob=$slider/knob

var option_hovered:bool=false

@export var isSlider:bool=false
@onready var sliderStartPos:float=$slider/startPos.position.x
@onready var sliderEndPos:float=$slider/endPos.position.x


#Slider stuffff 
@export var sliderMaxVal:int=10
@export var sliderStepAmount:float=1
var sliderValue:float=sliderMaxVal
var sliderProgress:float=1
var sliderMoveTime:float=0.2
var sliderMoveCount:float=0

@export var highlightEffectStart:String
@export var highlightEffectEnd:String

@export var sample_sound:AudioStreamWAV
@export var soundAudioBus:String
@onready var soundPlayer = $AudioExample

@export var path_checkbox_on:String
@export var path_checkbox_off:String
@export var option_active:bool=false


var cooldownCounter:float=0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text.text=tr(localizationID)
	
	if isSlider:
		$slider.show()
		soundPlayer.stream=sample_sound
		soundPlayer.bus=soundAudioBus
		UpdateSliderPos()

	else:
		$slider.hide()

	
		
func SetSliderProgress(_progress:float):
	sliderProgress=_progress
	sliderValue=sliderProgress*sliderMaxVal
	UpdateSliderPos()
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !option_hovered:
		cooldownCounter=0
		return
	elif cooldownCounter<0.01:
		cooldownCounter+=delta
		return

	
	if !isSlider:
		UpdateButton()
	else:
		UpdateSlider(delta)
	
	
	
	
func UpdateButton():
	if Input.is_action_just_pressed("jump"):
		if RequireExtraConfirmation:
			if hasclickedonce:
				button_pressed.emit(self)	
			else:
				hasclickedonce=true
				extraConfirmzationMessage.text=tr(extraConfirmationMessageLocalizationID)
				extraConfirmzationMessage.show()
		else:
			button_pressed.emit(self)

	
func UpdateSlider(delta:float):
	
	if Input.is_action_just_pressed("right"):
		MoveSlider(true)

	if Input.is_action_just_pressed("left"):
		MoveSlider(false)	
	
	if Input.is_action_pressed("right") or Input.is_action_pressed("left"):
		sliderMoveCount+=delta
		if sliderMoveCount>sliderMoveTime:
			sliderMoveCount=0
			if Input.is_action_pressed("right"):
				MoveSlider(true)
			if Input.is_action_pressed("left"):
				MoveSlider(false)
	else:
		sliderMoveCount=0

func UpdateSliderPos():
	var progress=sliderValue/sliderMaxVal
	sliderKnob.position.x=sliderStartPos+(abs(sliderStartPos-sliderEndPos))*progress

func MoveSlider(right:bool):
	if right:
		sliderValue=min(sliderMaxVal, sliderValue+sliderStepAmount)
	else:
		sliderValue=max(0, sliderValue-sliderStepAmount)
		
	UpdateSliderPos()
	
	sliderProgress=sliderValue/sliderMaxVal
	sliderValueChanged.emit(optionName,sliderProgress)
	UpdateSoundTest(true)
	
	pass

func SetActive(_active:bool):
	if RequireExtraConfirmation:
		hasclickedonce=false
		extraConfirmzationMessage.hide()
	option_hovered=_active
	
	var txt="[center]"
	if option_hovered:
		txt+=highlightEffectStart
		
	txt+=tr(localizationID)

	if isToggle:
		if option_active:
			txt+="[img]"+path_checkbox_on+"[/img]"
		else:
			txt+="[img]"+path_checkbox_off+"[/img]"

	if option_hovered:
		txt+=highlightEffectEnd	
	
	txt+="[/center]"
	
	text.text=txt
	

	UpdateSoundTest(option_hovered)
	

	
	#TODO: A bit of a wiggle :) 

func UpdateSoundTest(active:bool):
	
	if active and isSlider:
		if !soundPlayer.playing:
			soundPlayer.play()
	else:
		soundPlayer.stop()
		
	
	pass
