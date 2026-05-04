extends Node2D
@onready var button:button_hold=$InteractButton_acceptDeal

var bodiesInAcceptanceArea:int=0

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
	
	LoadIntoCursedMode()
	
	pass # Replace with function body.

func LoadIntoCursedMode():
	
	var savehandler:save_manager=GlobalVariables.MainSceneReferenceConnector.mainScene
	savehandler.ChangeToCursedMode()
	HUD.ResetGame()
	
	pass
