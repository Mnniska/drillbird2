extends Node2D

#handling the shop
signal ShopClosed
@onready var moneyUI=$"../CashHolder/cashNumber"

#add continue button to UI_Purchasables
@export var UI_purchasables:Array[Node2D]

@export var abstract_purchasables:Array[abstract_purchasable]
var shopActive:bool=false
#playerstats 
var currentSelection:int=0

# Called when the node enters the scene tree for the first time.

func _ready():
	GlobalVariables.playerMoneyChange.connect(PlayerMoneyChanged)
	
	SetupShop()

func PlayerMoneyChanged():
	moneyUI.text=str(GlobalVariables.playerMoney)+" xp"
	pass
func SetupShop():
	var index:int=0
	moneyUI.text=str(GlobalVariables.playerMoney)+" xp"
	for n in UI_purchasables:
		if index!=UI_purchasables.size()-1: #The last item is not setup since it's a simple btn
			n.Setup(abstract_purchasables[index])
		n.SetSelected( index==currentSelection)
		index+=1



func SetActive(active:bool):
	shopActive=active
	
	if active:
		show()
		GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.SHOP
		UpdateShop()
		
	else:
		GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.NEWDAY
		ShopClosed.emit()
		
		hide()
		

func UpdateShop():
	var index:int=0
	for n in UI_purchasables:
		#ensure setselected is implemented
		n.SetSelected( index==currentSelection)
		index+=1
			

func AttemptPurchaseSelectedItem():
	
	if UI_purchasables[currentSelection].AttemptToPurchase():
		
		moneyUI.text=str(GlobalVariables.playerMoney)+" xp"
		var type = abstract_purchasables[currentSelection].type
		var playerUpgradeLvl=GlobalVariables.GetPlayerUpgradeLevel(type)
		
		var upgrade= abstract_purchasables[currentSelection].items[playerUpgradeLvl+1]
		if upgrade!=null:
			GlobalVariables.SetPlayerUpgradeLevel(type,playerUpgradeLvl+1)
			UI_purchasables[currentSelection].UpdateStats()
			UpdateShop()
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_PURCHASE_YES)
			#Tell UI to update itself
		
	else:
		SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_PURCHASE_NO)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !shopActive:
		return 
	
	#Check if player wants to move up or down
	var changeDone:bool=false
	if Input.is_action_just_pressed("up"):
		currentSelection-=1
		changeDone=true
		SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_UP)
	if Input.is_action_just_pressed("down"):
		currentSelection+=1
		changeDone=true
		SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_DOWN)

	if changeDone:
		if currentSelection<0:
			currentSelection=abstract_purchasables.size()-1
		if currentSelection>abstract_purchasables.size()-1:
			currentSelection=0
		UpdateShop()
	
	if Input.is_action_just_pressed("jump"):
		
		#if current selection is a button, call that btn instead
		PressCurrentItem()
		
	pass
	
func PressCurrentItem():
	
	if UI_purchasables[currentSelection].isButton():
		SetActive(false)
	else:
		AttemptPurchaseSelectedItem()
	
	pass
	


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	SetActive(true)
	pass # Replace with function body.
