extends Node2D
class_name menu_option

signal button_pressed(option:menu_option)
signal sliderValueChanged(menuName:String,progress:float)

@export var OptionInfo:abstract_menu_option

@onready var text=$RichTextLabel
@onready var sliderKnob=$slider/knob

var active:bool=false

@onready var sliderStartPos:float=$slider/startPos.position.x
@onready var sliderEndPos:float=$slider/endPos.position.x


#Slider stuffff 
@export var sliderMaxVal:int=10
@export var sliderStepAmount:float=1
var sliderValue:float=sliderMaxVal
var sliderProgress:float=1


@export var highlightEffectStart:String
@export var highlightEffectEnd:String

@export var sample_sound:AudioStreamWAV
@export var soundAudioBus:String
@onready var soundPlayer = $AudioExample

@export var path_checkbox_on:String
@export var path_checkbox_off:String
@export var option_active:bool=false:
	get:return option_active
	set(value):
		option_active=value


var cooldownCounter:float=0

func Setup(option:abstract_menu_option):
	OptionInfo=option
	text.text=OptionInfo.optionName
	
	if OptionInfo.isSlider:
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
	sliderValueChanged.emit(OptionInfo.optionName,sliderProgress)
	UpdateSoundTest(true)
	
	pass

func SetActive(_active:bool):
	active=_active
	
	var txt="[center]"
	if active:
		txt+=highlightEffectStart
		
	txt+=OptionInfo.optionName

	if OptionInfo.isToggle:
		if option_active:
			txt+="[img]"+path_checkbox_on+"[/img]"
		else:
			txt+="[img]"+path_checkbox_off+"[/img]"

	if active:
		txt+=highlightEffectEnd	
	
	txt+="[/center]"
	
	text.text=txt
	

	UpdateSoundTest(active)
	

	
	#TODO: A bit of a wiggle :) 

func UpdateSoundTest(active:bool):
	
	if active and OptionInfo.isSlider:
		if !soundPlayer.playing:
			soundPlayer.play()
	else:
		soundPlayer.stop()
		
	
	pass
