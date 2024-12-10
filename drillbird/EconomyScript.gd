extends Node2D

@onready var sellNumber = $"../Camera2D/CashHolder/cashNumber"
@onready var seller = get_parent().get_node("Camera2D/InventoryHandler")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sellNumber.text=str(GlobalVariables.playerMoney)

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	GlobalVariables.playerMoney+= seller.SellOres()
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	sellNumber.text=str(GlobalVariables.playerMoney)
	
	pass # Replace with function body.
