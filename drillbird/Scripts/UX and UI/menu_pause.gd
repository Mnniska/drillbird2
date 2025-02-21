extends Node2D
@export var options:Array[menu_option]
signal signal_pause_menu_closed

var menuActive:bool=false
var selectedOption:int=0
var oldSelection:int=0
var isHoldingEscape:bool=false

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
