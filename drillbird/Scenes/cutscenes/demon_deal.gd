extends Node2D
@onready var button:button_hold=$InteractButton_acceptDeal
@export var demonCutscene:demon_reincarnation_cutscene
var bodiesInAcceptanceArea:int=0
@onready var demonSprite=$AnimatedSprite2D

var dialogueFinished:bool=false

@onready var dialoguePlayer:dialogue_player=$"Demon Dialogue"


@export var dialouge_playerNotReady:Array[abs_dialogue_line]
@export var dialouge_ready:Array[abs_dialogue_line]
@export var debugIgnoreWhetherEggHasBeenHatched:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.SetActive(false)
	dialoguePlayer.dialogueFinished.connect(SetDialogueFinished)
	dialoguePlayer.aboutToPlay.connect(DialogueAboutToPlay)
	
	await GlobalVariables.SetupComplete
	hasHatchedEgg=GlobalVariables.normalEndingFound
	if debugIgnoreWhetherEggHasBeenHatched:
		hasHatchedEgg=true


@export var hasHatchedEgg:bool=false

func DialogueAboutToPlay():
	#updates the demon dialogue depending on if player has hatched eggg before or not
	
	var _linesToPlay:Array[abs_dialogue_line]
	if hasHatchedEgg:
		_linesToPlay=dialouge_ready
	else:
		_linesToPlay=dialouge_playerNotReady
	
	dialoguePlayer.linesToPlay=_linesToPlay

	

func SetDialogueFinished():
	dialogueFinished=true
	button.SetActive(bodiesInAcceptanceArea>0 and dialogueFinished) #called when dialogue finishes in case player already stands in acceptance area


func _on_deal_acceptance_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if !hasHatchedEgg:
		return
	bodiesInAcceptanceArea+=1
	
	button.SetActive(bodiesInAcceptanceArea>0 and dialogueFinished and hasHatchedEgg)
	pass # Replace with function body.


func _on_deal_acceptance_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:

		
	bodiesInAcceptanceArea-=1
	button.SetActive(bodiesInAcceptanceArea>0 and dialogueFinished and hasHatchedEgg)
	pass # Replace with function body.


func _on_interact_button_accept_deal_button_pressed() -> void:
	button.SetActive(false)
	
	if demonCutscene:
		demonSprite.hide()
		demonCutscene.PlayCutscene()
	
		demonCutscene.connect("cutscene_finished",CutsceneFinished)
	
	
	pass # Replace with function body.

func CutsceneFinished():
	LoadIntoCursedMode()

	pass

func LoadIntoCursedMode():
	
	var savehandler:save_manager=GlobalVariables.MainSceneReferenceConnector.mainScene
	savehandler.ChangeToCursedMode()
	HUD.ResetGameToCursedMode()
	
	pass
