extends Node2D
@onready var button:button_hold=$InteractButton_acceptDeal
@export var demonCutscene:demon_reincarnation_cutscene
var bodiesInAcceptanceArea:int=0
@onready var demonSprite=$AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.SetActive(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_deal_acceptance_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	bodiesInAcceptanceArea+=1
	
	button.SetActive(bodiesInAcceptanceArea>0)
	pass # Replace with function body.


func _on_deal_acceptance_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	bodiesInAcceptanceArea-=1
	button.SetActive(bodiesInAcceptanceArea>0)
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
