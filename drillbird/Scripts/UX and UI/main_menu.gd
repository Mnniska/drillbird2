extends Control

signal NewGame
signal press_options
signal press_quit

@export var options:Array[abstract_debugMenuOption]
@onready var menuText=$mainMenuText
var textbegin="[center]"
var textend="[/center]"

var selectionEffectBegin="[wave amp=50.0 freq=5.0 connected=1]"
var selectionEffectEnd="[/wave]"

var selection:int=0

var active:bool=false
var cooldown:float=0

var fadeValue:float=1
var shouldBeVisible:bool=true
var timeToFade:float=1
var fadeCounter:float=2

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	

	if !active:
		cooldown=0
		return
	else:
		cooldown+=delta
		if cooldown<0.4:
			return
		
	if Input.is_action_just_pressed("up"):
		selection-=1
		if selection<0:
			selection=options.size()-1
		GenerateMainMenu()
	if Input.is_action_just_pressed("down"):
		selection+=1
		if selection>options.size()-1:
			selection=0
		GenerateMainMenu()
	
	if Input.is_action_just_pressed("jump"):
		PressButton()
	
	if shouldBeVisible and fadeValue<1:
		fadeCounter=min(timeToFade,fadeCounter+delta)
		fadeValue=fadeCounter/timeToFade
		UpdateMenuFade(fadeValue)
		
	if !shouldBeVisible and fadeValue>0:
		fadeCounter=max(0,fadeCounter-delta)
		fadeValue=fadeCounter/timeToFade
		UpdateMenuFade(fadeValue)


	pass

func GenerateMainMenu():
	
	active=true
	#If the player starts the game during day 1, we can assume they do not ahve an active save game
	if GlobalVariables.currentDay==1:
		options[0].name="menu_new_game"
	else:
		options[0].name="menu_continue"
	
	var textstring=textbegin
	
	var index:int=0
	for option in options:
		if selection==index:
			textstring+=selectionEffectBegin
			
		textstring+=tr(option.name)+"\n"
		
		if selection==index:
			textstring+=selectionEffectEnd
		index+=1
	
	textstring+=textend
	menuText.text=textstring

func Deactivate():
	active=false
	hide()
	
func PressButton():
	
	match options[selection].name:
		"menu_new_game":
			NewGame.emit()
		"menu_continue":
			NewGame.emit()
		"menu_options":
			press_options.emit()
		"menu_quit":
			press_quit.emit()
	

func SetShouldBeVisible(visible:bool):
	shouldBeVisible=visible
	
	if visible:
		menuText.show()
	else:
		menuText.hide()
	

func UpdateMenuFade(progress:float):
	
	var color=Color(Color.WHITE,progress)
	self.modulate=color
	
		

	
