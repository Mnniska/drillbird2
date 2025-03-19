extends Node2D
signal ButtonPressed(optionName:String)
signal SliderMoved(optionName:String,movedRight:bool)


@export var menuOptions:Array[abstract_menu_option]
var currentmenu:Array[abstract_menu_option]
var currentMenu_physical:Array[menu_option]
var currentSelection:int=0

var holdingRightCounter:float=0
var holdingleftCounter:float=0
var holdTime:float=0.3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	currentmenu=menuOptions
	GenerateMenu(currentmenu)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	#move up and down in menu
	if Input.is_action_just_pressed("down"):
		currentSelection+=1
		if currentSelection>=currentmenu.size():
			currentSelection=0
		UpdateActive()
		
	if Input.is_action_just_pressed("up"):
		currentSelection-=1
		if currentSelection<0:
			currentSelection=currentmenu.size()-1
		UpdateActive()
	
	#press a non-slider btn
	if Input.is_action_just_pressed("jump"):
		var current = currentmenu[currentSelection]
		if !current.isSlider:
			PressButton(current)
	
	
	#Handles moving sliders
	if Input.is_action_just_pressed("left"):
		var current = currentmenu[currentSelection]
		if current.isSlider:
			MoveSlider(false,current)
	
	if Input.is_action_just_pressed("right"):
		var current = currentmenu[currentSelection]
		if current.isSlider:
			MoveSlider(true,current)
	
	if Input.is_action_pressed("right"):
		var current = currentmenu[currentSelection]
		if current.isSlider:
			holdingleftCounter=0
			holdingRightCounter+=delta
			if holdingRightCounter>holdTime:
				holdingRightCounter=0
				MoveSlider(true,current)
	
	if Input.is_action_pressed("left"):
		var current = currentmenu[currentSelection]
		if current.isSlider:
			holdingRightCounter=0
			holdingleftCounter+=delta
			if holdingleftCounter>holdTime:
				holdingleftCounter=0
				MoveSlider(false,current)
	
	pass

func UpdateActive():
	var index=0
	for node in currentMenu_physical:
		node.SetActive(index==currentSelection)
		index+=1
			
	

func GenerateMenu(menu:Array[abstract_menu_option]):
	for node in currentMenu_physical:
		node.queue_free()
	
	currentMenu_physical.clear()
	
	var yCoord=0
	var index=0
	for option in currentmenu:
		var path = load("res://Scenes/UI/menu_option.tscn")
		var node:menu_option = path.instantiate()
		node.transform.origin=Vector2(0,yCoord)
		add_child(node)
		node.Setup(option)
		node.SetActive(currentSelection==index)
		
		currentMenu_physical.append(node)
		if option.isSlider:
			yCoord+=24
		else:
			yCoord+=16
		index+=1
		pass
	
func PressButton(option:abstract_menu_option):
	if option.goesDeeper:
		currentmenu=option.subMenu
		GenerateMenu(currentmenu)
		currentSelection=0
		return
	
	ButtonPressed.emit(option.optionName)
	

	
func BackOut():
	currentmenu=menuOptions
	GenerateMenu(currentmenu)


func MoveSlider(right:bool,option:abstract_menu_option):
	
	SliderMoved.emit(option.optionName,right)
	
	pass
