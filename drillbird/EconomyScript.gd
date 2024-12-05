extends Node2D

var playerMoney:int=0
@onready var sellNumber = $"../Camera2D/CashHolder/cashNumber"
@onready var seller = get_parent().get_node("Camera2D/InventoryHandler")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	playerMoney+= seller.SellOres()
	print_debug("Player now has "+str(playerMoney)+" money!")
	sellNumber.text=str(playerMoney)
	
	pass # Replace with function body.
