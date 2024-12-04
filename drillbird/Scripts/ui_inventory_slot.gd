extends Node2D

"""
The InventorySlot keeps track of the ores it has and updates itself visually
"""
var oreTex:Texture2D
@onready var current = $current
@onready var max = $max
var new_ore: abstract_ore
var chosen_ore: abstract_ore
var maxItems:int =3
var currentItems: int =0
var occupied:bool = false

func GiveOre(_newore:abstract_ore):
	new_ore =_newore
	
	if(currentItems==0):
		chosen_ore=new_ore
			
	if(maxItems>currentItems):
		
		currentItems+=1
		
		
	
	pass



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chosen_ore=null
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
