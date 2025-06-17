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
@onready var icon:AnimatedSprite2D=$IconContainer/icon
@onready var Header=$StatHeader
@onready var Description=$StatExplanation
@onready var purchaseBtn= $PurchaseButton
@onready var cost=$PurchaseButton/Cost

#upgrade knobs 
#@onready var KnobStartPos=$KnobStartPos
@export var tex_knob_active:Texture2D
@export var tex_knob_inactive:Texture2D
var maxedOut:bool=false
var knobArray:Array[Sprite2D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func GetCurrentUpgrade():
	return GlobalVariables.GetPlayerUpgradeLevel(purchasable.type)

func AttemptToPurchase():
	#CAN PLAYER AFFORD UPGRADE?
	if purchasable.items.size()>GetCurrentUpgrade()+1:
		var cost:int=purchasable.items[GetCurrentUpgrade()+1].cost
		if GlobalVariables.playerMoney>=cost:
			GlobalVariables.playerMoney-=cost
			return true
			pass
		else:
			var diff:int=cost- GlobalVariables.playerMoney
			print_debug("Cannot afford upgrade! You need "+str(cost)+" more dollars!")
			return false
	else:
		print_debug("You're maxed out!")
		return false
	

func SetupKnobs():
	
	var index:int=0
	for n in purchasable.items.size()-1:
		var sprite = Sprite2D.new()
		sprite.z_index=2
		$KnobStartPos.add_child(sprite) 
		knobArray.append(sprite)
	pass

func UpdateKnobs():
	var dist_off:int=4
	var dist_on:int=6
	var offset:int=0
	
	var index:int=0
	for n in knobArray:
		n.position.x=offset
		
		#Color knobs if they're ugpraded
		if index < GetCurrentUpgrade():
			n.texture=tex_knob_active
			offset+=dist_on
		else:
			n.texture=tex_knob_inactive
			offset+=dist_off
			pass
		index+=1
	pass

func isButton():
	#this is used by the shop to determine whether they're dealing with a shop item or a btnmm
	return false
	
func SetSelected(selected:bool):
	UpdateTranslation()
	var canAfford:bool=false
	if purchasable.items.size()>GetCurrentUpgrade()+1:
		canAfford = purchasable.items[GetCurrentUpgrade()+1].cost<=GlobalVariables.playerMoney
		pass
	
	if selected:
		background.texture=tex_bg_on
		iconContainer.texture=tex_icon_on
		icon.play()
		
		if canAfford:
			purchaseBtn.texture=tex_btn_selected_affordable
		else:
			purchaseBtn.texture=tex_btn_selected_expensive
			pass
		
	else:
		background.texture=tex_bg_off
		iconContainer.texture=tex_icon_off
		icon.stop()
		
		if canAfford:
			purchaseBtn.texture=tex_btn_inactive_affordable
		else:
			purchaseBtn.texture=tex_btn_inactive_expensive
			
	
func UpdateStats():
	
	var animToPlay=""
	match purchasable.type:
		GlobalVariables.typeEnum.DRILL:
			animToPlay="drill_active"
			pass
		GlobalVariables.typeEnum.LIGHT:
			animToPlay="fuel_active"
			pass
		GlobalVariables.typeEnum.INVENTORY:
			animToPlay="inventory_active"
			pass
		GlobalVariables.typeEnum.HEALTH:
			animToPlay="health_active"
			pass
	
	icon.animation=animToPlay

	var playerLevel=GetCurrentUpgrade()
	if purchasable.items.size()>playerLevel+1:
		cost.text=str( purchasable.items[ playerLevel+1].cost)
	else:
		cost.text="Max"
	UpdateKnobs()

func UpdateTranslation():
	Header.text=tr(purchasable.itemNameID)
	Description.text=tr(purchasable.itemDescriptionID)
	pass

func Setup(_purchasable:abstract_purchasable):
	purchasable=_purchasable
	SetupKnobs()
	UpdateStats()
	UpdateTranslation()



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
