extends Node2D

"""
The InventorySlot keeps track of the ores it has and updates itself visually
"""
var oreTex:Texture2D
@onready var numberVisual_current = $current
@onready var numberVisual_max = $max
var new_ore: abstract_ore
var chosen_ore: abstract_ore
var maxItems:int =3
var currentItems: int =0
var occupied:bool = false

func GiveOre(_newore:abstract_ore):
	new_ore =_newore
	
	if(currentItems==0):
		chosen_ore=new_ore
			
	if(currentItems<maxItems):
		currentItems+=1
		UpdateVisuals()
	else:
		return false
		
	
	pass
	
func RemoveOre():
	if currentItems<=0:
		return false
	else:
		currentItems-=1
		if(currentItems==0):
			chosen_ore=null
		UpdateVisuals()

func UpdateVisuals():
	numberVisual_current.setNumber(currentItems)
	numberVisual_max.setNumber(maxItems)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chosen_ore=null
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
