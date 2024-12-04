extends Node2D

"""
The InventorySlot keeps track of the ores it has and updates itself visually
"""
var oreTex:Texture2D
@onready var current = $current
@onready var max = $max
var maxItems:int =3
var currentItems: int =0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
