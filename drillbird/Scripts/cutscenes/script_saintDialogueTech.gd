extends Node2D

enum States{unfound,spawned,destroyed,isSoul,soulgiven}
var currentState:States=States.unfound
var isTalking:bool=false

@onready var InteractButton=$InteractButton_talkToSaint
@onready var interactButtonText=$InteractButton_talkToSaint/HBoxContainer/text_feedEgg
@onready var interactButtonSymbol=$InteractButton_talkToSaint/HBoxContainer/iconHolder/text_icon

@export var dialogueWhenTooLate:Array[abs_dialogue_line]
@export var dialogueWhenInTime:Array[abs_dialogue_line]

@export var dialogueWhenEggNotReady:Array[abs_dialogue_line]
@export var dialogueWhenEggReady:Array[abs_dialogue_line]

@export var greetingLineAfterFirstIntroduction:Array[abs_dialogue_line]


@export var soulOre:abstract_ore

@onready var dialoguePlayer=$Dialogue

var hasGreetedPlayer:bool=false

var isCoolingDown:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	await GlobalVariables.SetupComplete
	
	InteractButton.hide()
	
var interactButtonShowTimer:float=0
var playerCanInteract:bool=false

func _process(delta: float) -> void:
	
	if currentState==States.spawned:
		if playerClose:
			interactButtonShowTimer=min(0.1,interactButtonShowTimer+delta)
		else:
			interactButtonShowTimer=max(interactButtonShowTimer-delta,0)
			
		if interactButtonShowTimer>=0.1 and !isTalking and !isCoolingDown:
			interactButtonSymbol.text="[center]"+GlobalSymbolRegister.GetSymbolFromString("(sing)",true)
			interactButtonText.text=tr("saint_to_talk")

			InteractButton.show()
			playerCanInteract=true
		else:
			InteractButton.hide()
			playerCanInteract=false
		
		if playerCanInteract and Input.is_action_just_pressed("sing") and !isCoolingDown:
			UpdateDialogueAfterInitialInteraction()
	
	else:
		InteractButton.hide()
		playerCanInteract=false

	
		
func UpdateDialogueAfterInitialInteraction():
	
	await get_tree().create_timer(0.02).timeout #adding a timer so that the dialogue script does not think ther player is singing when dialogue starts
	UpdateDialogue() #this wikll automatically set the dialogue depending on the eggs status
	dialoguePlayer.StartDialogue()
	isTalking=true #this is set to false when dialogue finishes - uses to hide the interact btn

func UpdateDialogue():
	#called when dialogue is about to play, updates it to current dialogue needs
	
	
	
	var dialogueToPlay:Array[abs_dialogue_line]
	
	if GlobalVariables.currentDay <= GlobalVariables.daysBeforeDemonKillsEgg: #if saint isn't dead yet
		
		#Initial inttroduction - saint is spawned and explains the situation
		if !hasGreetedPlayer:
			dialogueToPlay=dialogueWhenInTime
			hasGreetedPlayer=true
			currentState=States.spawned
			saintShouldSayHello=false
		else:
			if saintShouldSayHello:
				saintShouldSayHello=false
				for line in greetingLineAfterFirstIntroduction:
					dialogueToPlay.append(line)
			#enum eggStates{NOTHING,GROWING,FINALFORM_NO_HEART,FINALFORM_HEART,FINALCUTSCENE}

		#If egg is ready 
		if GlobalVariables.eggState==2 or GlobalVariables.eggState==3:
			currentState=States.isSoul
			for line in dialogueWhenEggReady:
				dialogueToPlay.append(line)
				
		 
		#if egg is not ready
		if GlobalVariables.eggState==1:
			currentState=States.spawned
			for line in dialogueWhenEggNotReady:
				dialogueToPlay.append(line)
		
	else:
		dialogueToPlay=dialogueWhenTooLate
		currentState=States.destroyed
	
	dialoguePlayer.linesToPlay=dialogueToPlay
	dialoguePlayer.dialogueFinished.connect(dialogueFinished)
	
func dialogueFinished():
	
	isTalking=false
	
	if currentState==States.isSoul:
		SpawnSaintOre()
	
	isCoolingDown=true
	await get_tree().create_timer(1).timeout
	isCoolingDown=false
	
	
	pass

func SpawnSaintOre():
	var oreSpawner:ore_manager=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	var location = $oreSpawnLocation.global_position
	oreSpawner.SpawnOreAtLocation(location,soulOre,Vector2(0,0),true,false)

var playerClose:bool=false
func _on_dialogue_trigger_area_body_entered(_body: Node2D) -> void:
	
	#if saint has been found it will hopefully be chilling, can be talked to via button prompt
	if currentState==States.unfound:
		UpdateDialogue()
		dialoguePlayer.StartDialogue()
		isTalking=true
	
	playerClose=true
	pass # Replace with function body.

func _on_dialogue_trigger_area_body_exited(_body: Node2D) -> void:
	playerClose=false
	pass # Replace with function body.

var saintShouldSayHello:bool=false
func _on_player_entering_area_trigger_body_entered(_body: Node2D) -> void:
	#this trigger is used to make the saint greet the player if they're spawned. If the player talk to he saint multiple times,
	#we don't want the saint to keep saying hello 
	saintShouldSayHello=true
