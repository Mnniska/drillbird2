extends Node2D

signal optionsClosed

@onready var soundPlayer = $AudioExample
@export var options:Array[menu_option]

var menuActive:bool=false
var selectedOption:int=0
var oldSelection:int=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	UpdateMenu()
	SetupMenu()
	SetActive(menuActive)
	pass # Replace with function body.

func SetupMenu():
	for n in options:
		if n.isSlider:
			n.sliderValueChanged.connect(SliderValueChanged)
		else:
			n.button_pressed.connect(ButtonPressed)
	pass

func SetActive(_active:bool):
	menuActive=_active
	if menuActive:
		show()
		UpdateMenu()
	else:
		hide()
		for n in options:
			
			n.SetActive(false)
	

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
	
	pass

func UpdateMenu():
	var index=0
	for n in options:
		n.SetActive(index==selectedOption)
		index+=1
	pass

func ButtonPressed(_name:String):
	if _name=="Return":
		SetActive(false)
		optionsClosed.emit()
	pass

func SliderValueChanged(_name:String,_progress:float):
	var chosenBus
	
	match _name:
		"Master Volume":
			chosenBus=AudioServer.get_bus_index("Master")

		"SFX Volume":
			chosenBus=AudioServer.get_bus_index("Sfx")
		"Music Volume":
			chosenBus=AudioServer.get_bus_index("Music")
		"Ambience Volume":
			chosenBus=AudioServer.get_bus_index("Ambience")
	
	
	AudioServer.set_bus_volume_db(chosenBus,linear_to_db(_progress))
		
	
	pass
