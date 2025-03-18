extends Node2D

signal optionsClosed

@export var options:Array[menu_option]

var menuActive:bool=false
var selectedOption:int=0
var oldSelection:int=0


var save_file_path = "user://save/"
var save_file_name="DrillbirdPlayerPreferences.tres"
var PlayerPreferences=abstract_player_preferences.new()

var isFullscreen:bool=false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	verify_save_directory(save_file_path)
	LoadPreferences()
	
	UpdateMenu()
	SetupMenu()
	SetActive(menuActive)
	


	pass # Replace with function body.

func verify_save_directory(path:String):
	DirAccess.make_dir_absolute(path)

func SavePreferences():
	for n in options:
		SaveSliderValue(n.optionName,n.sliderProgress)	
	ResourceSaver.save(PlayerPreferences,save_file_path+save_file_name)
	print_debug("game preferences saved")
	

		
func SaveSliderValue(_name:String,_progress:float):
	match _name:
		"Master Volume":
			PlayerPreferences.volumeMaster=_progress
		"SFX Volume":
			PlayerPreferences.volumeSFX=_progress
		"Music Volume":
			PlayerPreferences.volumeMusic=_progress
		"Ambience Volume":
			PlayerPreferences.volumeAmbience=_progress
	
func LoadPreferences():
	if ResourceLoader.load(save_file_path+save_file_name)!=null:
		PlayerPreferences=ResourceLoader.load(save_file_path+save_file_name)

	SliderValueChanged("Master Volume",PlayerPreferences.volumeMaster)
	SliderValueChanged("SFX Volume",PlayerPreferences.volumeSFX)
	SliderValueChanged("Music Volume",PlayerPreferences.volumeMusic)
	SliderValueChanged("Ambience Volume",PlayerPreferences.volumeAmbience)
	
	for n in options:
		match n.optionName:
			"Master Volume":
				n.SetSliderProgress(PlayerPreferences.volumeMaster)
			"SFX Volume":
				n.SetSliderProgress(PlayerPreferences.volumeSFX)
			"Music Volume":
				n.SetSliderProgress(PlayerPreferences.volumeMusic)
			"Ambience Volume":
				n.SetSliderProgress(PlayerPreferences.volumeAmbience)		

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
		
	if Input.is_action_just_pressed("escape"):
		var escapeOption:menu_option=menu_option.new()
		escapeOption.optionName="Return"
		ButtonPressed(escapeOption)
		escapeOption.queue_free()
	
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

func ButtonPressed(_option:menu_option):
	if _option.optionName=="Return":
		SavePreferences()
		SetActive(false)
		optionsClosed.emit()

	if _option.optionName=="Toggle Fullscreen":
		isFullscreen=!isFullscreen
		_option.option_active=isFullscreen
		_option.SetActive(true)
		
		if isFullscreen:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WindowMode.WINDOW_MODE_WINDOWED)


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
