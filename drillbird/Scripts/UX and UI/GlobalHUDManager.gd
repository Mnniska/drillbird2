extends CanvasLayer

@onready var HUD_lightBulbManager=$topUI/LightHandler
@onready var HUD_healthManager=$topUI/HealthUIHandler
@onready var HUD_cashText=$topUI/CashHolder/cashNumber
@onready var HUD_InventoryManager=$bottomUI/InventoryHandler

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func GetLightManager():
	return HUD_lightBulbManager
