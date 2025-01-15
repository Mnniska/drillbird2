extends Node2D

"""
The InventorySlot keeps track of the ores it has and updates itself visually
"""
var oreTex:Texture2D
@onready var numberVisual_current = $current
@onready var numberVisual_max = $max
@onready var slashVisual=$txt_slash
@onready var oreVisual=$ore
var chosen_ore: abstract_ore
var maxItems:int =3
var currentItems: int =0
var occupied:bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#TODO: Maybe save inventory down the line
	chosen_ore=null
	UpdateVisuals()
	
	pass # Replace with function body.

func GiveOre(_newore:abstract_ore):

	if(currentItems<0):
		AssignOre(_newore)
			
	if(currentItems<maxItems && chosen_ore.name==_newore.name):
		currentItems+=1
		UpdateVisuals()
		return true
	else:
		return false
		

func AssignOre(_newore:abstract_ore):
	chosen_ore=_newore
	maxItems=chosen_ore.stackSize
	oreVisual.texture=chosen_ore.texture
	currentItems=0
	UpdateVisuals()

func SellOres():
	var gainedMoney:int =0
	if(currentItems>0):
		gainedMoney+=currentItems*chosen_ore.value
	currentItems=-1
	maxItems=-1
	chosen_ore=null
	UpdateVisuals()
	return gainedMoney
	
	pass
	
func EmptyOres():
	var oreList:Array[abstract_ore]
	for n in currentItems:
		oreList.append(chosen_ore)

	currentItems=0
	chosen_ore=null
	UpdateVisuals()
	
	return oreList

func RemoveOre():
	if currentItems<=0:
		return false
	else:
		currentItems-=1
		if(currentItems==0):
			chosen_ore=null
		UpdateVisuals()

func UpdateVisuals():
	if(chosen_ore==null):
		oreVisual.hide()
		currentItems=-1
		maxItems=-1
		slashVisual.hide()
	else:
		oreVisual.show()
		slashVisual.show()
		
	numberVisual_current.setNumber(currentItems)
	numberVisual_max.setNumber(maxItems)




# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
