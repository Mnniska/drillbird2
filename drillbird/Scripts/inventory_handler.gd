extends Node
class_name inventory_handler
"""
The inventory_handler has an array of available inventory slots. When the player picks up a new ore, 
the inventory_handler is called to ask if it can be slotted in anywhere.
The handler is also called when selling - it will empty the inventory and sell it for money 
The handler is also called when the player wants to drop something

TLDR inventory_handler manages inventory size as well as adding and removing ores from the player's inventory
"""

@export var upgradetree_inventory:abstract_purchasable
var OreSpawner

var inventorySlots : Array[ui_inventory_slot]
#var inventorySlots =Array[preload("res://Scenes/UI_InventorySlot.tscn")]
var slotAmount:int=2
@onready var UIvisual_left = $ui_leftSide
@onready var UIvisual_right = $ui_rightSide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Inventory.connect(upgradeChangeInventory)
	GlobalVariables.SetupComplete.connect(InitializationCompleteSetup)
	#Todo: Read the inventoryStat from globalVariables and figure out how much the player should have based on that
	
	for n in upgradetree_inventory.items[GlobalVariables.upgradeLevel_inventory].power:
		var scene = load("res://Scenes/UI/UI_InventorySlot.tscn") 
		var node = scene.instantiate()
		var offset= Vector2(-16,-16)
		node.transform.origin =  Vector2(16*n,0)+offset
		add_child(node)
		
		inventorySlots.append(node)
		pass
	UpdateInventoryPositions()
	pass # Replace with function body.

func InitializationCompleteSetup():
	OreSpawner=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	if OreSpawner==null:
		push_error("Could not connect OreSpawner in inventory_handler!")

func DropOresRequest(position:Vector2,velocity:Vector2,facingRight:bool):
	var oresToDrop:Array[abstract_ore]
	for n in inventorySlots:
		for p in n.EmptyOres():
			oresToDrop.append(p)

	for n in oresToDrop:
		var flip=-1
		if facingRight:
			flip=1
		var x=(randf_range(50,100)+velocity.x)*flip
		var y = randf_range(-100,-200)+velocity.y
		var v=Vector2(x,y)
		
		OreSpawner.SpawnOreAtLocation(position,n,v,true)


func GetIsThereAnythingSellable():
	for n in inventorySlots:
		if n.currentItems>0:
			return true
	return false
	pass

func GetOresInInventory():
	var ores:Array[abstract_ore]
	
	for n in inventorySlots:
		for count in n.currentItems:
			var ore:abstract_ore=n.chosen_ore.duplicate()
			ores.append(ore)
	
	return ores

func SellOres():
	var gainedMoney:int=0
	for n in inventorySlots:
		gainedMoney+=n.SellOres()
		#get money from sell fucntion in the ore slot
	return gainedMoney
	
func PlayerDied(playerPos:Vector2):
	DropOresRequest(playerPos,Vector2(0,0),true)




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
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.ORE_GRABBED)
			break
	
	return oreAdded


	

func AddSlotRequest():
	var scene = load("res://Scenes/UI/UI_InventorySlot.tscn") 
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
