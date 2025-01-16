extends Node
"""
The inventory_handler has an array of available inventory slots. When the player picks up a new ore, 
the inventory_handler is called to ask if it can be slotted in anywhere.
The handler is also called when selling - it will empty the inventory and sell it for money 
The handler is also called when the player wants to drop something

TLDR inventory_handler manages inventory size as well as adding and removing ores from the player's inventory
"""

@export var upgradetree_inventory:abstract_purchasable
@onready var OreSpawner=$"../../TilemapOres"

var inventorySlots : Array[Node2D]
#var inventorySlots =Array[preload("res://Scenes/UI_InventorySlot.tscn")]
var slotAmount:int=2
@onready var UIvisual_left = $ui_leftSide
@onready var UIvisual_right = $ui_rightSide

func DropOresRequest(position:Vector2):
	var oresToDrop:Array[abstract_ore]
	for n in inventorySlots:
		for p in n.EmptyOres():
			oresToDrop.append(p)

	for n in oresToDrop:
		var x=randf_range(-200,200)
		var y = randf_range(-100,-200)
		var v=Vector2(x,y)
		
		OreSpawner.SpawnOreAtLocation(position,n,v,true)


func GetIsThereAnythingSellable():
	for n in inventorySlots:
		if n.currentItems>0:
			return true
	return false
	pass

func SellOres():
	var gainedMoney:int=0
	for n in inventorySlots:
		gainedMoney+=n.SellOres()
		#get money from sell fucntion in the ore slot
	return gainedMoney
	
func PlayerDied(playerPos:Vector2):
	DropOresRequest(playerPos)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Inventory.connect(upgradeChangeInventory)
	
	#Todo: Read the inventoryStat from globalVariables and figure out how much the player should have based on that
	
	for n in upgradetree_inventory.items[GlobalVariables.upgradeLevel_inventory].power:
		var scene = load("res://Scenes/UI_InventorySlot.tscn") 
		var node = scene.instantiate()
		var offset= Vector2(-16,-16)
		node.transform.origin =  Vector2(16*n,0)+offset
		add_child(node)
		
		inventorySlots.append(node)
		pass
	UpdateInventoryPositions()
	pass # Replace with function body.

func UpdateInventoryPositions():
	var offset:int=0
	offset=(floor(inventorySlots.size())/2)*16
	if(inventorySlots.size()%2>0):
		offset+=8
		pass
	var index:int =0 
	for n in inventorySlots:
		n.position.x=self.position.x- offset+(16*index)
		index+=1
	
	UIvisual_left.position.x=-offset-8
	UIvisual_right.position.x=-offset+((inventorySlots.size()+1)*16)-8

func AddOreRequest(ore:abstract_ore):
	var oreAdded:bool=false
	for n in inventorySlots:
		if n.GiveOre(ore):
			oreAdded=true
			print_debug("Ore added!")
			break
	
	return oreAdded


	

func AddSlotRequest():
	var scene = load("res://Scenes/UI_InventorySlot.tscn") 
	var node = scene.instantiate()
	var offset= Vector2(-16,-16)
	inventorySlots.append(node)
	node.transform.origin =  Vector2(16*inventorySlots.size(),0)+offset
	add_child(node)
		
	UpdateInventoryPositions()


func upgradeChangeInventory():
	if !GlobalVariables.InitialSetup:
		AddSlotRequest()
	pass # Replace with function body.
