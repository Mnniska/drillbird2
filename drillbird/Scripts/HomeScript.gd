extends Node2D
@onready var SellButton= $InteractButton_depositOres
@onready var RestButton = $InteractButton_EndDay
@onready var inventory = HUD.HUD_InventoryManager
@onready var moneyUI=HUD.HUD_cashText
@onready var animSleep=$Eggs/BirdySleepPositions/birdySleep
@onready var Player=$"../Player"
@onready var Shop = $"../Camera2D/ShopHandler"
@onready var LightHandler=HUD.HUD_lightBulbManager
@onready var Camera=$"../Camera2D"
@onready var CameraLerpPosition=$CameraLerpPosition
@onready var HealthHandler=HUD.HUD_healthManager
@onready var EggHandler:egg_script =$Eggs
@onready var OreSellVisualizer=$OreSellParent

var oresBeingSold:int=0


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

	
	if state==states.SELL:
		if Input.is_action_just_pressed("interact"):
			pass
			#This is done via a collider now 	
	if state==states.RESTPOSSIBLE:
		
		if Input.is_action_pressed("up"):
			ProgressGoToBed(delta,true)
		else:
			ProgressGoToBed(delta,false)
	
	UpdateButtons()
	pass

func CheckState():
	
	if state==states.SLEEP or state==states.SELLING:
		UpdateButtons()
		return

	if $NestCollider.get_overlapping_bodies().size()>0:
	
		if inventory.GetIsThereAnythingSellable():
			state=states.SELL
			
		else:
			state=states.RESTPOSSIBLE
	else:
		state=states.IDLE

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

#SELLING ORES
func _on_sell_ore_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	SellOre(body)
	

func SellOre(_ore:Node2D):
	oresBeingSold+=1
	var oreType:abstract_ore=_ore.GetOre()
	GlobalVariables.GivePlayerMoney( oreType.value)
	moneyUI.text=str(GlobalVariables.playerMoney)+"xp"
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	
	var visualizer:ore_sell_visualizer = OreSellVisualizer.SellThisOre(oreType,_ore)
	visualizer.finishedSelling.connect(OreFinishedSelling)
	_ore.queue_free()
	state=states.SELLING

func OreFinishedSelling(amount:int):
	oresBeingSold-=1
	EggHandler.UpdateSize(EggHandler.oldXP+amount)
	
	if oresBeingSold<=0:
		await get_tree().create_timer(1).timeout
		state=states.IDLE
		CheckState()
	
	pass
	


func MainMenu_SetupSleepIdle():
	
	animSleep.animation="asleep"
	animSleep.play()
	animSleep.show()
	
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

func WakeUp(saveGame:bool):
	
	if saveGame:
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
	WakeUp(true)#temporary - will do a custom one later
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
	
	CheckState()
	$JustWokeUpTimer.start()
	UpdateButtons()

	pass # Replace with function body.

func _on_just_woke_up_timer_timeout() -> void:
	justWokeUp=false
	CheckState()

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
	WakeUp(true)	
	pass # Replace with function body.
