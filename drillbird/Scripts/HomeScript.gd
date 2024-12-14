extends Node2D
@onready var SellButton= $InteractButton_depositOres
@onready var RestButton = $InteractButton_EndDay
@onready var inventory = $"../Camera2D/InventoryHandler"
@onready var seller=$"../Camera2D/InventoryHandler"
@onready var moneyUI=$"../Camera2D/CashHolder/cashNumber"
@onready var animSleep=$birdySleep
@onready var Player=$"../Player"
@onready var Shop = $"../Camera2D/ShopHandler"


enum states{IDLE,SELL,RESTPOSSIBLE}
var state:states


#take care of UI buttons
#check player inventory and display deposit ores when in range 
#call sell function when depositing ores 
#add "rest day" btn if no ores to sell
#implement "are you sure" popup when ending day
#set up sell and shop screen 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animSleep.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state==states.IDLE:
		return
	
	if state==states.SELL:
		if Input.is_action_just_pressed("interact"):
			SellOres()
	
	if state==states.RESTPOSSIBLE:
		if Input.is_action_just_pressed("interact"):
			GoToBed()
	
	CheckState()
	UpdateButtons()
	
	
	
	pass

func CheckState():
	
	if inventory.GetIsThereAnythingSellable():
		state=states.SELL
		
	else:
		state=states.RESTPOSSIBLE

func UpdateButtons():
	match state:
		states.SELL:
			SellButton.show()
			RestButton.hide()

		states.RESTPOSSIBLE:
			RestButton.show()
			SellButton.hide()
		states.IDLE:
			RestButton.hide()
			SellButton.hide()

func SellOres():
	GlobalVariables.playerMoney+= seller.SellOres()
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	moneyUI.text=str(GlobalVariables.playerMoney)+" xp"

func GoToBed():
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.SHOP
	Player.hide()
	
	animSleep.show()
	animSleep.animation="layingdown"
	animSleep.play()
	
	$cutsceneTimer.start()

func WakeUp():
	Player.show()
	animSleep.hide()
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
	
func _on_nest_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	CheckState()
	pass # Replace with function body.


func _on_nest_collider_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	state=states.IDLE
	UpdateButtons()

	pass # Replace with function body.


func _on_birdy_sleep_animation_finished() -> void:
	if animSleep.animation=="layingdown":
		animSleep.animation="asleep"
		animSleep.play()
	pass # Replace with function body.


func _on_cutscene_timer_timeout() -> void:
	Shop.SetActive(true)
	pass # Replace with function body.


func _on_shop_handler_shop_closed() -> void:
	WakeUp()	
	pass # Replace with function body.
