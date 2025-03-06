extends Node2D
class_name inventory_handler

signal signal_pickedUpHeart
signal signal_droppedHeart(heart:Node2D)

"""
The inventory_handler has an array of available inventory slots. When the player picks up a new ore, 
the inventory_handler is called to ask if it can be slotted in anywhere.
The handler is also called when selling - it will empty the inventory and sell it for money 
The handler is also called when the player wants to drop something

TLDR inventory_handler manages inventory size as well as adding and removing ores from the player's inventory
"""

var OreSpawner

var inventorySlots : Array[ui_inventory_slot]
#var inventorySlots =Array[preload("res://Scenes/UI_InventorySlot.tscn")]
var slotAmount:int=2
@export var inventoryUpgradeTree:abstract_purchasable

var isFull:bool=false
var currentWeight:int=0
var maxWeight:int=10
var carriedOres:Array[abstract_ore]
@onready var inventoryNumber=$inventoryNumber
@export var textPreface="[right]"

var oreLerpVisual=preload("res://Scenes/Effects/ore_sell_visualizer.tscn")
var lerpingOres:Array[ore_sell_visualizer]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.upgradeChange_Inventory.connect(upgradeChangeInventory)
	GlobalVariables.SetupComplete.connect(InitializationCompleteSetup)



func InitializationCompleteSetup():
	OreSpawner=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	SetupInventorySize()

	if OreSpawner==null:
		push_error("Could not connect OreSpawner in inventory_handler!")

func DropOresRequest(position:Vector2,velocity:Vector2,facingRight:bool):



	for ore in carriedOres:
		var flip=-1
		if facingRight:
			flip=1
		var x=(randf_range(50,100)+velocity.x)*flip
		var y = randf_range(-100,-200)+velocity.y
		var v=Vector2(x,y)
		OreSpawner.SpawnOreAtLocation(position,ore,v,true)

	currentWeight=0
	UpdateInventoryText()
	carriedOres.clear()


func GetIsThereAnythingSellable():
	
	return currentWeight>0

func GetOresInInventory():
	
	return carriedOres

func SellOres():
	var gainedMoney:int=0
	
	for ore in carriedOres:
		gainedMoney+=ore.value
		currentWeight-=ore.weight
	
	carriedOres.clear()
	
	return gainedMoney

	
func PlayerDied(playerPos:Vector2):
	DropOresRequest(playerPos,Vector2(0,0),true)





func AddOreRequest(ore:abstract_ore):
	
	if currentWeight >= maxWeight:
		return false
	
	currentWeight = min(maxWeight,currentWeight+ore.weight) #increase weight
		
	isFull = currentWeight >= maxWeight
	
	carriedOres.append(ore)
	CreateLerpingOre(ore)
	SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.ORE_GRABBED)

	if ore.ID==10:
		signal_pickedUpHeart.emit()
	
	return true

func CreateLerpingOre(ore:abstract_ore):
	
	var sellPos=$icon.global_position
	
	var node:ore_sell_visualizer=oreLerpVisual.instantiate()
	add_child(node)
	node.position=$oreSpawnOrigin.position
		
	node.Setup(ore,sellPos,0,4,true)
	node.finishedSelling.connect(OreFinishedLerp)
	
	pass

func OreFinishedLerp(amount:int):
	UpdateInventoryText()
	pass

func UpdateInventoryText():
	inventoryNumber.text=textPreface+str(currentWeight)+"/"+str(maxWeight)+"kg"

	

func SetupInventorySize():
	maxWeight = inventoryUpgradeTree.items[GlobalVariables.upgradeLevel_inventory].power
	UpdateInventoryText()


func upgradeChangeInventory():
	if !GlobalVariables.InitialSetup:
		SetupInventorySize()
	pass # Replace with function body.
