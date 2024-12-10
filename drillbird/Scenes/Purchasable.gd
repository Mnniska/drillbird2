extends Node2D

@export var tex_bg_on:Texture2D
@export var tex_bg_off:Texture2D
@export var tex_icon_off:Texture2D
@export var tex_icon_on:Texture2D
@export var tex_btn_selected_expensive:Texture2D
@export var tex_btn_selected_affordable:Texture2D
@export var tex_btn_inactive_expensive:Texture2D
@export var tex_btn_inactive_affordable:Texture2D



var purchasable:abstract_purchasable

#onready prep:
@onready var background=$Background
@onready var iconContainer=$IconContainer
@onready var icon=$IconContainer/icon
@onready var Header=$StatHeader
@onready var Description=$StatExplanation
@onready var purchaseBtn= $PurchaseButton
@onready var cost=$PurchaseButton/Cost

#upgrade knobs 
#@onready var KnobStartPos=$KnobStartPos
@export var tex_knob_active:Texture2D
@export var tex_knob_inactive:Texture2D
var knobArray:Array[Sprite2D]

#economy
@export var playerMoney:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func AttemptToPurchase():
	#CAN PLAYER AFFORD UPGRADE?
	
	if purchasable.items[purchasable.currentUpgradeLevel+1] != null:
		var cost:int=purchasable.items[purchasable.currentUpgradeLevel+1].cost
		if GlobalVariables.playerMoney>=cost:
			GlobalVariables.playerMoney-=cost
			return true
			pass
		else:
			var diff:int=cost- GlobalVariables.playerMoney
			print_debug("Cannot afford upgrade! You need "+str(cost)+" more dollars!")
			return false
	

func SetupKnobs():
	
	var dist_off:int=4
	var dist_on:int=6
	var offset:int=0
	
	var index:int=0
	for n in purchasable.items.size():
		var sprite = Sprite2D.new()
		sprite.z_index=2
		$KnobStartPos.add_child(sprite) 
		knobArray.append(sprite)
		
		sprite.position.x=offset
		
	
		if index < purchasable.currentUpgradeLevel:
			sprite.texture=tex_knob_active
			offset+=dist_on
		else:
			sprite.texture=tex_knob_inactive
			offset+=dist_off

			pass

		
		index+=1
		
	
	
	pass

func SetSelected(selected:bool):
	
	var canAfford:bool = purchasable.items[purchasable.currentUpgradeLevel].cost<=playerMoney
	
	if selected:
		background.texture=tex_bg_on
		iconContainer.texture=tex_icon_on
		
		if canAfford:
			purchaseBtn.texture=tex_btn_selected_affordable
		else:
			purchaseBtn.texture=tex_btn_selected_expensive
			pass
		
	else:
		background.texture=tex_bg_off
		iconContainer.texture=tex_icon_off
		
		if canAfford:
			purchaseBtn.texture=tex_btn_inactive_affordable
		else:
			purchaseBtn.texture=tex_btn_inactive_expensive
			
	

func Setup(_purchasable:abstract_purchasable):
	purchasable=_purchasable
	icon.texture=purchasable.icon
	Header.text=purchasable.itemName
	Description.text=purchasable.itemDescription
	cost.text=str( purchasable.items[purchasable.currentUpgradeLevel+1].cost)
	SetupKnobs()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
