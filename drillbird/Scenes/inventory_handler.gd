extends Node
"""
The inventory_handler has an array of available inventory slots. When the player picks up a new ore, 
the inventory_handler is called to ask if it can be slotted in anywhere.
The handler is also called when selling - it will empty the inventory and sell it for money 
The handler is also called when the player wants to drop something

TLDR inventory_handler manages inventory size as well as adding and removing ores from the player's inventory
"""

var inventorySlots : Array[Node2D]
#var inventorySlots =Array[preload("res://Scenes/UI_InventorySlot.tscn")]
var slotAmount:int=4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for n in slotAmount:
		var scene = load("res://Scenes/UI_InventorySlot.tscn") 
		var node = scene.instantiate()
		var offset= Vector2(-16,-16)
		node.transform.origin =  Vector2(16*n,0)+offset
		add_child(node)
		
		inventorySlots.append(node)
		pass
	
	pass # Replace with function body.

func AddOreRequest(ore:abstract_ore):
	var oreAdded:bool=false
	for n in inventorySlots:
		if n.GiveOre(ore):
			oreAdded=true
			print_debug("Ore added!")
			break
	
	return oreAdded

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
