extends Node2D

signal optionsClosed

@onready var options_header=$Header
@onready var optionScroller=$OptionScroller

#created in ready by getting the menu_options thta are children to script
var EntireMenu:Array[menu_option]
@export var BaseMenu:Array[menu_option]
var CurrentMenu:Array[menu_option]

var menuActive:bool=false
var selectedOption:int=0
var oldSelection:int=0


var save_file_path = "user://save/"
var save_file_name="DrillbirdPlayerPreferences.tres"
var PlayerPreferences=abstract_player_preferences.new()

var isFullscreen:bool=false
var hauntedByGhost:bool=true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrentMenu=BaseMenu
	for child in get_children():
		if child is menu_option:
			EntireMenu.append(child)
			
			#loop through the options in the language menu as well so that we can listen to their signals
		if child is option_scroller:
			for child2 in child.get_children(): 
				if child2 is menu_option:
					EntireMenu.append(child2)
			pass
			
	verify_save_directory(save_file_path)
	LoadPreferences()
	
	


	
	UpdateMenu()
	SetupMenuSignals()
	SetMenuActive(menuActive)
	

	pass # Replace with function body.

func verify_save_directory(path:String):
	DirAccess.make_dir_absolute(path)

func SavePreferences():
	for n in EntireMenu:
		if n.isSlider:
			SaveSliderValue(n.optionName,n.sliderProgress)
		if n.isToggle:
			SaveToggleValue(n.optionName,n.option_active)
	ResourceSaver.save(PlayerPreferences,save_file_path+save_file_name)
	print_debug("game preferences saved")
	

func SaveToggleValue(_name:String,_on:bool):
	match _name:
		"Haunted by Ghost":
			PlayerPreferences.ghostActive=_on
		"Toggle Fullscreen":
			PlayerPreferences.fullscreenActive=_on


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
	#Responsible for setting the game's options to have the same values as the saved options - and updating the sliders and stuff to match said options
	if ResourceLoader.load(save_file_path+save_file_name)!=null:
		PlayerPreferences=ResourceLoader.load(save_file_path+save_file_name)

	#This sets up the game's audio buses to have the correct volume based on saved settings
	SliderValueChanged("Master Volume",PlayerPreferences.volumeMaster)
	SliderValueChanged("SFX Volume",PlayerPreferences.volumeSFX)
	SliderValueChanged("Music Volume",PlayerPreferences.volumeMusic)
	SliderValueChanged("Ambience Volume",PlayerPreferences.volumeAmbience)
	
	
	#This sets the sliders up so that they have the correct value
	for n in EntireMenu:
		match n.optionName:
			"Master Volume":
				n.SetSliderProgress(PlayerPreferences.volumeMaster)
			"SFX Volume":
				n.SetSliderProgress(PlayerPreferences.volumeSFX)
			"Music Volume":
				n.SetSliderProgress(PlayerPreferences.volumeMusic)
			"Ambience Volume":
				n.SetSliderProgress(PlayerPreferences.volumeAmbience)
			"Toggle Fullscreen":
				SetFullscreenActive(PlayerPreferences.fullscreenActive) 
				n.option_active=PlayerPreferences.fullscreenActive
			"Haunted by Ghost":
				GlobalVariables.ghostActive= PlayerPreferences.ghostActive 
				n.option_active=PlayerPreferences.ghostActive
				pass

func SetupMenuSignals():
	for n in EntireMenu:
		if n.isSlider:
			n.sliderValueChanged.connect(SliderValueChanged)
		else:
			n.button_pressed.connect(ButtonPressed)
	pass

func SetMenuActive(_active:bool):
	menuActive=_active
	if menuActive:
		show()
		UpdateMenu()
	else:
		hide()
		for n in EntireMenu:
			n.SetActive(false)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !menuActive:
		return
		
	if Input.is_action_just_pressed("escape") or Input.is_action_just_pressed("escape_light"):
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
			selectedOption=CurrentMenu.size()-1
		
		if selectedOption > CurrentMenu.size()-1:
			selectedOption = 0
		
		optionScroller.NewTarget(selectedOption)
		UpdateMenu()
	
	pass

func UpdateMenu():
	
	options_header.text="[center]"+tr("menu_options")
	
	for option in EntireMenu:
		option.hide()
		option.option_hovered=false
	
	var index=0
	for n in CurrentMenu:
		n.show()
		n.SetActive(index==selectedOption)
		index+=1
	pass

func ButtonPressed(_option:menu_option):
	
	#Note: "Return" is called when pressing escape, and is used in all sub-menus. basically a "back out" btn
	#Note: Only supports 1 layer deep submenus, which should be fine for our purposes  
	if _option.optionName=="Return":
		if CurrentMenu!=BaseMenu:
			CurrentMenu=BaseMenu
			selectedOption=0
			UpdateMenu()
		else:
			SavePreferences()
			SetMenuActive(false)
			optionsClosed.emit()
	
	#Enter the menu within a menu option, if it has any
	if _option.options.size()>0:
		selectedOption=0
		CurrentMenu=_option.options
		UpdateMenu()

	if _option.optionName=="Toggle Fullscreen":
		isFullscreen=!isFullscreen
		_option.option_active=isFullscreen
		_option.SetActive(true)
		SetFullscreenActive(isFullscreen)
	

	if _option.optionName=="Haunted by Ghost":
		hauntedByGhost=!hauntedByGhost
		_option.option_active=hauntedByGhost
		_option.SetActive(true)
		GlobalVariables.ghostActive=hauntedByGhost

	if _option.optionName=="Reset Save Data":
		GlobalVariables.ResetSaveData()
		HUD.QuitGame()
		
		
	if _option.optionName=="lang_sv":
		SetLanguage("sv")
		pass
	if _option.optionName=="lang_en":
		SetLanguage("en")
		pass
	if _option.optionName=="lang_ru":
		SetLanguage("ru")
		pass
	if _option.optionName=="lang_zh":
		SetLanguage("zh")
		pass
	if _option.optionName=="lang_ja":
		SetLanguage("ja")
		pass
	if _option.optionName=="lang_fr":
		SetLanguage("fr")
		pass
	if _option.optionName=="lang_de":
		SetLanguage("de")
		pass

func SetLanguage(lang:String):
	TranslationServer.set_locale(lang)
 
	UpdateMenu()
	GlobalVariables.MainSceneReferenceConnector.shop.UpdateShop()
	

	

func SetFullscreenActive(active:bool):
	isFullscreen=active
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
