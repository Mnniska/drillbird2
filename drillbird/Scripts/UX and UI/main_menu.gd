extends Node2D

signal NewGame

@export var options:Array[abstract_debugMenuOption]
@onready var menuText=$mainMenuText
var textbegin="[center]"
var textend="[/center]"

var selectionEffectBegin="[wave amp=50.0 freq=5.0 connected=1]"
var selectionEffectEnd="[/wave]"

var selection:int=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GenerateMainMenu()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("down"):
		selection-=1
		if selection<0:
			selection=options.size()-1
		GenerateMainMenu()
	if Input.is_action_just_pressed("up"):
		selection+=1
		if selection>options.size()-1:
			selection=0
		GenerateMainMenu()
	
	if Input.is_action_just_pressed("jump"):
		PressButton()
	
	pass

func GenerateMainMenu():
	var textstring=textbegin
	
	var index:int=0
	for option in options:
		if selection==index:
			textstring+=selectionEffectBegin
			
		textstring+=option.name+"\n"
		
		if selection==index:
			textstring+=selectionEffectEnd
		index+=1
	
	textstring+=textend
	menuText.text=textstring

func PressButton():
	
	match options[selection].name:
		"New Game":
			NewGame.emit()
		"Options":
			pass
	
	pass
