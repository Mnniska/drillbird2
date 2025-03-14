extends Node2D
@export var options:Array[menu_option]
signal signal_pause_menu_closed

var menuActive:bool=false
var selectedOption:int=0
var oldSelection:int=0
var isHoldingEscape:bool=false

var hasClickedQuitOnce:bool=false
@onready var quitInfoText=$QuitConfirmation

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

func ButtonPressed(_name:String):
	if _name=="Return":
		SetActive(false)
		signal_pause_menu_closed.emit()
	
	if _name=="Options":
		SetActive(false)
		HUD.SetState(HUD.menuStates.OPTIONS)
		
	if _name=="Quit Game":
		
		if !hasClickedQuitOnce:
			

			var end_time = Time.get_unix_time_from_system() #captures the end time in unix time
			var elapsed_time = (end_time - GlobalVariables.timeLastSaved) / 60 #this calculates the elapsed time in minutes - divisor will need to be adjusted if you want hours, days, etc.
			
			quitInfoText.text="[center]Last save was made "+str(floor(elapsed_time))+" minutes ago.[p][center] Are you sure you'd like to quit? "
			
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
	
	if Input.is_action_just_pressed("escape") and !isHoldingEscape:
		ButtonPressed("Return")
		
	if Input.is_action_just_released("escape"):
		isHoldingEscape=false
			
	
	pass

func SetActive(_active:bool):
	menuActive=_active
	if menuActive:

		show()
		UpdateMenu()
		isHoldingEscape=true
		hasClickedQuitOnce=false
		quitInfoText.hide()
	else:
		hide()
		for n in options:
			
			n.SetActive(false)

func UpdateMenu():
	var index=0
	for n in options:
		n.SetActive(index==selectedOption)
		index+=1
	

	
	pass
