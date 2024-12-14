extends Node2D

#handling the shop
@onready var moneyUI=$"../CashHolder/cashNumber"


@export var UI_purchasables:Array[Node2D]
@export var abstract_purchasables:Array[abstract_purchasable]
var shopActive:bool=false
#playerstats 
var currentSelection:int=0

# Called when the node enters the scene tree for the first time.

func _ready():
	SetupShop()

func SetupShop():
	var index:int=0
	moneyUI.text=str(GlobalVariables.playerMoney)+" xp"
	for n in UI_purchasables:
		n.Setup(abstract_purchasables[index])
		n.SetSelected( index==currentSelection)
		index+=1
			

func SetActive(active:bool):
	shopActive=active
	
	if active:
		show()
		GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.SHOP
		
	else:
		GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
		hide()
		

func UpdateShop():
	var index:int=0
	for n in UI_purchasables:
		n.SetSelected( index==currentSelection)
		index+=1
			

func PurchaseSelectedItem():
	
	if UI_purchasables[currentSelection].AttemptToPurchase():
		
		moneyUI.text=str(GlobalVariables.playerMoney)+" xp"
		var type = abstract_purchasables[currentSelection].type
		var playerUpgradeLvl=GlobalVariables.GetPlayerUpgradeLevel(type)
		
		var upgrade= abstract_purchasables[currentSelection].items[playerUpgradeLvl+1]
		if upgrade!=null:
			GlobalVariables.SetPlayerUpgradeLevel(type,playerUpgradeLvl+1)
			UI_purchasables[currentSelection].UpdateStats()
			UpdateShop()
			#Tell UI to update itself
		pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !shopActive:
		return 
	
	#Check if player wants to move up or down
	var changeDone:bool=false
	if Input.is_action_just_pressed("up"):
		currentSelection-=1
		changeDone=true
	if Input.is_action_just_pressed("down"):
		currentSelection+=1
		changeDone=true

	if changeDone:
		if currentSelection<0:
			currentSelection=abstract_purchasables.size()-1
		if currentSelection>abstract_purchasables.size()-1:
			currentSelection=0
		UpdateShop()
	

	if Input.is_action_just_pressed("jump"):
		PurchaseSelectedItem()
	pass
	
	
	if Input.is_action_just_pressed("drill"):
		SetActive(false)
	pass


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	SetActive(true)
	pass # Replace with function body.
