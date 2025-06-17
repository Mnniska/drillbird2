extends Node2D
@export var options:Array[menu_option]
signal signal_pause_menu_closed

var menuActive:bool=false
var selectedOption:int=0
var oldSelection:int=0
var isHoldingEscape:bool=false
@onready var instructions_text=$instructions
var hasClickedQuitOnce:bool=false
@onready var quitInfoText=$QuitConfirmation

@onready var daycounter:RichTextLabel=$DayCounter

@onready var text_header = $Header
@onready var text_instructions=$instructions

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetActive(false)
	SetupMenu()
	pass # Replace with function body.

func SetupMenu():
	for n in options:
		if !n.isSlider:
			n.button_pressed.connect(ButtonPressed)
	pass

func ButtonPressed(_option:menu_option):
	if _option.optionName=="Return":
		SetActive(false)
		signal_pause_menu_closed.emit()
	
	if _option.optionName=="Options":
		SetActive(false)
		HUD.SetState(HUD.menuStates.OPTIONS)
		
	if _option.optionName=="Quit Game":
		
		if !hasClickedQuitOnce:
			

			var end_time = Time.get_unix_time_from_system() #captures the end time in unix time
			var elapsed_time = (end_time - GlobalVariables.timeLastSaved) / 60 #this calculates the elapsed time in minutes - divisor will need to be adjusted if you want hours, days, etc.
			
			quitInfoText.text=tr("options_quit_warning_part1")+str(floor(elapsed_time))+" "+tr("options_quit_warning_part2")
			
			quitInfoText.show()
			hasClickedQuitOnce=true
		else:
			get_tree().quit()
		
		pass
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !menuActive:
		return
	
	if Input.is_action_just_pressed("down"):
		selectedOption+=1

	if Input.is_action_just_pressed("up"):
		selectedOption-=1	
	
	if selectedOption!=oldSelection:
		oldSelection=selectedOption
	
		if selectedOption<0:
			selectedOption=options.size()-1
		
		if selectedOption > options.size()-1:
			selectedOption = 0

		UpdateMenu()
	
	if Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("escape_light"):
		if  !isHoldingEscape:
			var option:menu_option=menu_option.new()
			option.optionName="Return"
			option.queue_free()
			
			ButtonPressed(option)
		
	if Input.is_action_just_released("escape"):
		isHoldingEscape=false
	
	pass

func SetActive(_active:bool):
	
	text_header.text="[center][font_size={32}]"+tr("menu_paused")+"[/font_size][p]"+"[center]"+tr("menu_day")+str(GlobalVariables.currentDay)
	text_instructions.text=tr("menu_instructions")
	
	menuActive=_active
	if menuActive:

		show()
		UpdateMenu()
		isHoldingEscape=true
		hasClickedQuitOnce=false
		quitInfoText.hide()
		daycounter.text=""
		
	else:
		hide()
		for n in options:
			
			n.SetActive(false)

func UpdateMenu():
	var index=0
	for n in options:
		n.SetActive(index==selectedOption)
		index+=1
	UpdateTutorialInstructions()
	
func UpdateTutorialInstructions():
	var decodedText = GlobalSymbolRegister.GetStringDecoded(tr("menu_instructions"))
	instructions_text.text=decodedText
	
	
