extends Node2D
@onready var SellButton= $InteractButton_depositOres
@onready var RestButton = $InteractButton_EndDay
@onready var inventory = $"../Camera2D/bottomUI/InventoryHandler"
@onready var moneyUI=$"../Camera2D/topUI/CashHolder/cashNumber"
@onready var animSleep=$Eggs/BirdySleepPositions/birdySleep
@onready var Player=$"../Player"
@onready var Shop = $"../Camera2D/ShopHandler"
@onready var LightHandler=$"../Camera2D/topUI/LightHandler"
@onready var Camera=$"../Camera2D"
@onready var CameraLerpPosition=$CameraLerpPosition
@onready var HealthHandler=$"../Camera2D/topUI/HealthUIHandler"
@onready var EggHandler =$Eggs
@onready var OreSellVisualizer=$OreSellParent



var targetEggXP:int=0
var xpGained:int=0
var oldEggXP:int=0


@export var holdTime:float=1
var holdCounter:float=0
var justWokeUp:bool=false


var ambienceSound:AudioStreamPlayer2D

enum states{IDLE,SELL,RESTPOSSIBLE,SLEEP,SELLING}
var state:states

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animSleep.hide()
	
	ambienceSound=SoundManager.CreatePersistentSound(global_position,abstract_SoundEffectSetting.SoundEffectEnum.AMBIENCE_SURFACE)
	ambienceSound.play()
	ambienceSound.finished.connect(ambienceSound.play)
	
	var HUBMusic:AudioStreamPlayer2D=SoundManager.CreatePersistentSound(global_position,abstract_SoundEffectSetting.SoundEffectEnum.MUSIC_HOME)
	HUBMusic.play()
	HUBMusic.finished.connect(HUBMusic.play)
	pass # Replace with function body.

func SetHoldProgress(progress:float):
	var min = 15
	var pos=lerp(min,0,progress)
	$InteractButton_EndDay/icon/active.position.y=pos
	
func ProgressGoToBed(delta:float,active:bool):
	
	if active:
		holdCounter+=delta
	elif holdCounter>0:
		holdCounter-=delta*2
		holdCounter=max(0,holdCounter)
	SetHoldProgress(holdCounter/holdTime)
	if holdCounter>holdTime:
		holdCounter=0
		GoToBed()
		
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:


	if state==states.IDLE or state==states.SLEEP:
		UpdateButtons()
		return
	
	if state==states.SELL:
		if Input.is_action_just_pressed("interact"):
			SellOres()
	
	if state==states.RESTPOSSIBLE:
		
		if Input.is_action_pressed("up"):
			ProgressGoToBed(delta,true)
		else:
			ProgressGoToBed(delta,false)
	
	CheckState()
	UpdateButtons()
	pass

func CheckState():
	
	if state==states.SLEEP:
		return
	
	if inventory.GetIsThereAnythingSellable() && !state==states.SELLING:
		state=states.SELL
		
	elif state!=states.SELLING:
		state=states.RESTPOSSIBLE

func UpdateButtons():
	match state:
		states.SELL:
			SellButton.show()
			RestButton.hide()
		states.SELLING:
			SellButton.hide()
			RestButton.hide()
		states.RESTPOSSIBLE:
			if !justWokeUp:
				RestButton.show()
			SellButton.hide()
		states.IDLE:
			RestButton.hide()
			SellButton.hide()
		states.SLEEP:
			RestButton.hide()
			SellButton.hide()

func SellOres():
	state=states.SELLING
	UpdateButtons()
	
	#OresellVisualizer is a purely visual spectactle to sell the player on selling
	OreSellVisualizer.SellTheseOres(inventory.GetOresInInventory(),Player)
	var moneyAmount=inventory.SellOres()
	$AutomaticIdleTimer.start()
	
	oldEggXP=GlobalVariables.totalExperienceGained
	
	GlobalVariables.GivePlayerMoney(moneyAmount)
	
	#When XP orb collides with home, it will be destroyed and egg size will be updated acc to progress towards targetXP
	xpGained=0
	targetEggXP = moneyAmount*OreSellVisualizer.eggXPGainVisualMultiplier
	
	#moneyUI.text=str(GlobalVariables.playerMoney)+"xp"
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	#EggHandler.UpdateSize()

func SellOre(ore:abstract_ore):
	GlobalVariables.GivePlayerMoney( ore.value)
	moneyUI.text=str(GlobalVariables.playerMoney)+"xp"
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	EggHandler.UpdateSize()
	
	pass

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
	GlobalVariables.currentDay+=1
	$"..".SaveGame()
	justWokeUp=true
	
	
	Camera.SetFollowPlayer(true)
	Player.position=$PlayerWakeupPos.position
	Player.show()
	animSleep.hide()
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
	
func ReplendishStats():
	LightHandler.RefillLight()
	HealthHandler.RefillHealth()
	pass
	
func Respawn():
	ReplendishStats()
	WakeUp()#temporary - will do a custom one later
	Player.state=Player.States.IDLE
	
	pass
	
func IsPlayerInCollider():
	return $NestCollider.get_overlapping_bodies().size()>0
	
	pass

func _on_nest_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	
	CheckState()
	$JustWokeUpTimer.stop()
	pass # Replace with function body.


func _on_nest_collider_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if state!=states.SELLING:
		state=states.IDLE
	$JustWokeUpTimer.start()
	UpdateButtons()

	pass # Replace with function body.

func _on_just_woke_up_timer_timeout() -> void:
	justWokeUp=false

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


func OreEnteredCollider(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	body.MoveTowardsHome(self.global_position)
	
	pass # Replace with function body.


func _on_ore_xp_collider_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.get_parent().MovingToObject:
		return
	
	area.get_parent().queue_free()
	EggHandler.UpdateSizeBasedOnSaveData(true)

	
func SellingComplete():
	state=states.IDLE
	if IsPlayerInCollider():
		if inventory.GetIsThereAnythingSellable():
			state=states.SELL
		else:
			state=states.RESTPOSSIBLE
	$AutomaticIdleTimer.stop()

func _on_automatic_idle_timer_timeout() -> void:
	if state==states.SELLING:
		state=states.IDLE
	
	pass # Replace with function body.
