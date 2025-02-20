extends Node2D
class_name menu_option

signal button_pressed
signal sliderValueChanged(menuName:String,progress:float)

@export var optionName:String
@export var isAction:bool=true

@onready var text=$RichTextLabel
@onready var sliderKnob=$slider/knob

var active:bool=false

@export var isSlider:bool=false
@onready var sliderStartPos:float=$slider/startPos.position.x
@onready var sliderEndPos:float=$slider/endPos.position.x

@export var sliderMaxVal:int=10
@export var sliderStepAmount:float=1
var sliderValue:float=sliderMaxVal
var sliderProgress:float=1


var sliderMoveTime:float=0.8
var sliderMoveCount:float=0

@export var highlightEffectStart:String
@export var highlightEffectEnd:String

@export var sample_sound:AudioStreamWAV
@export var soundAudioBus:String
@onready var soundPlayer = $AudioExample
var cooldown:float=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text.text=optionName
	if isSlider:
		$slider.show()
		soundPlayer.stream=sample_sound
		soundPlayer.bus=soundAudioBus
		UpdateSliderPos()

	else:
		$slider.hide()
	
	
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !active:
		cooldown=0
		return
	else:
		cooldown+=delta
		if cooldown<0.3:
			return
	
	if !isSlider:
		UpdateButton()
	else:
		UpdateSlider()
	
	
	pass
	
func UpdateButton():
	if Input.is_action_just_pressed("jump"):
		button_pressed.emit(optionName)
	
	
	
func UpdateSlider():
	
	if Input.is_action_just_pressed("right"):
		MoveSlider(true)

	if Input.is_action_just_pressed("left"):
		MoveSlider(false)	
	
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
	
	var progress=sliderValue/sliderMaxVal
	sliderValueChanged.emit(optionName,progress)
	UpdateSoundTest(true)
	
	pass

func SetActive(_active:bool):
	if _active==active:
		pass
	active=_active
	
	var txt="[center]"
	if active:
		txt+=highlightEffectStart
		
	txt+=optionName

	if active:
		txt+=highlightEffectEnd	
	
	txt+="[/center]"
	
	text.text=txt
	

	UpdateSoundTest(active)
	

	
	#TODO: A bit of a wiggle :) 

func UpdateSoundTest(active:bool):
	
	if active:
		if !soundPlayer.playing:
			soundPlayer.play()
	else:
		soundPlayer.stop()
		
	
	pass
