extends Node2D
@onready var SellButton= $InteractButton_depositOres
@onready var RestButton = $InteractButton_EndDay
@onready var inventory = $"../Camera2D/InventoryHandler"
@onready var seller=$"../Camera2D/InventoryHandler"
@onready var moneyUI=$"../Camera2D/CashHolder/cashNumber"
@onready var animSleep=$birdySleep
@onready var Player=$"../Player"
@onready var Shop = $"../Camera2D/ShopHandler"
@onready var LightHandler=$"../Camera2D/LightHandler"
@onready var Camera=$"../Camera2D"
@onready var CameraLerpPosition=$CameraLerpPosition


enum states{IDLE,SELL,RESTPOSSIBLE,SLEEP}
var state:states

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animSleep.hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state==states.IDLE or state==states.SLEEP:
		UpdateButtons()
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
	
	if state==states.SLEEP:
		return
	
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
		states.SLEEP:
			RestButton.hide()
			SellButton.hide()

func SellOres():
	GlobalVariables.playerMoney+= seller.SellOres()
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	moneyUI.text=str(GlobalVariables.playerMoney)+" xp"

func GoToBed():
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.SHOP
	state=states.SLEEP
	#hide stuff that only exists in reality
	Player.hide()
	
	#birdy goes to bed anim
	animSleep.show()
	animSleep.animation="layingdown"
	animSleep.play()
	
	#move camera
	Camera.StartNewLerp(CameraLerpPosition.position, 0.5)
	
	$cutsceneTimer.start()

func WakeUp():
	Camera.SetFollowPlayer(true)
	Player.position=$PlayerWakeupPos.position
	Player.show()
	animSleep.hide()
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
	
func ReplendishStats():
	LightHandler.RefillLight()
	pass
	
	
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
	ReplendishStats()
	pass # Replace with function body.


func _on_shop_handler_shop_closed() -> void:
	WakeUp()	
	pass # Replace with function body.
