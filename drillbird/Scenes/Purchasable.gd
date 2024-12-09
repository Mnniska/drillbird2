extends Node2D

@export var tex_bg_on:Texture2D
@export var tex_bg_off:Texture2D
@export var tex_icon_off:Texture2D
@export var tex_icon_on:Texture2D
@export var tex_btn_selected_expensive:Texture2D
@export var tex_btn_selected_affordable:Texture2D
@export var tex_btn_inactive_expensive:Texture2D
@export var tex_btn_inactive_affordable:Texture2D


@export var purchasable:abstract_purchasable

#onready prep:
@onready var background=$Background
@onready var iconContainer=$IconContainer
@onready var icon=$IconContainer/icon
@onready var Header=$StatHeader
@onready var Description=$StatExplanation
@onready var purchaseBtn= $PurchaseButton
@onready var cost=$PurchaseButton/Cost

#economy
@export var playerMoney:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Setup()
	pass # Replace with function body.

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
			
	

func Setup():
	icon.texture=purchasable.icon
	Header.text=purchasable.itemName
	Description.text=purchasable.itemDescription
	cost.text=str( purchasable.items[purchasable.currentUpgradeLevel].cost)
	
	SetSelected(true)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
