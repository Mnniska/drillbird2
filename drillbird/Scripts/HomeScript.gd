extends Node2D

#BUTTONS
@onready var SellButton= $InteractButton_depositOres
@onready var RestButton:button_hold = $InteractButton_EndDay
@onready var HatchEggButton:button_hold = $InteractButton_HatchEgg

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
@onready var TextBubble=preload("res://Scenes/UI/text_bubble.tscn")
@onready var MusicPlayer:hub_music_player=$HUBMusicPlayer

@onready var nestCutscene=$NestCutscene

var oresBeingSold:int=0

#REPLACE WITH HOLD BUTTON 
@export var holdTime:float=1
var holdCounter:float=0

var justWokeUp:bool=false

enum states{NO_EGG,IDLE,SELL,RESTPOSSIBLE,SLEEP,SELLING,FINALCUTSCENE}
var state:states=states.IDLE

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	UpdateButtons()
	pass

func CheckState():
	
	if HUD.state!=HUD.menuStates.PLAY:
		return
	
	if state==states.SLEEP or state==states.SELLING or state==states.FINALCUTSCENE or state==states.NO_EGG:
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
		states.NO_EGG:
			SellButton.SetActive(false)
			RestButton.SetActive(false)
			HatchEggButton.SetActive(false)
			pass
		states.SELL:
			SellButton.SetActive(true)
			RestButton.SetActive(false)
			if EggHandler.eggState==EggHandler.eggStates.FINALFORM_HEART:
				HatchEggButton.SetActive(true)
		states.SELLING:

			SellButton.SetActive(false)
			RestButton.SetActive(false)
			HatchEggButton.SetActive(false)
		states.RESTPOSSIBLE:

			if !justWokeUp:
				RestButton.SetActive(true)
				if EggHandler.eggState==EggHandler.eggStates.FINALFORM_HEART:
					HatchEggButton.SetActive(true)
			SellButton.SetActive(false)
	
	if state==states.SLEEP or state==states.IDLE or state==states.FINALCUTSCENE:
		RestButton.SetActive(false)
		HatchEggButton.SetActive(false)
		SellButton.SetActive(false)
			
		

func _on_interact_button_end_day_button_pressed() -> void:
	GoToBed()
	pass # Replace with function body.


#SELLING ORES
func _on_sell_ore_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	SellOre(body)
	

func SellOre(_ore:Node2D):
	
	var oreType:abstract_ore=_ore.GetOre()
	if oreType.ID==10:
		HeartEnteredCollider(_ore)
		return
		pass
		
	oresBeingSold+=1	
	GlobalVariables.GivePlayerMoney( oreType.value)
	moneyUI.text=str(GlobalVariables.playerMoney)+"xp"
	print_debug("Player now has "+str(GlobalVariables.playerMoney)+" money!")
	
	var visualizer:ore_sell_visualizer = OreSellVisualizer.SellThisOre(oreType,_ore)
	visualizer.finishedSelling.connect(OreFinishedSelling)
	_ore.queue_free()
	state=states.SELLING

func HeartEnteredCollider(_heart:Node2D):
	
	if EggHandler.eggState==EggHandler.eggStates.FINALFORM_NO_HEART:
		
		var visualizerPath=load("res://Scenes/Effects/ore_sell_visualizer.tscn")
		var visualizer:ore_sell_visualizer=visualizerPath.instantiate()
		add_child(visualizer)
		visualizer.global_position=_heart.global_position
		visualizer.Setup(_heart.GetOre(), $Eggs/Egg_FinalForm.GetFinalHeartPosition(),1)
		visualizer.isFinalHeart=true
		visualizer.finishedSelling.connect(FinalHeartPlaced)
		
		_heart.queue_free()

	
		print_debug("Got the heart and I was WAITING FOR IT")
	
	if EggHandler.eggState==EggHandler.eggStates.GROWING:
		var node:text_bubble=TextBubble.instantiate()
		add_child(node)
		node.position=OreSellVisualizer.position
		node.Setup(abstract_textEffect.effectEnum.WAVE,text_bubble.behaviourEnum.FADE)
		node.ShowText("I'm not ready yet..")
	
	
	if EggHandler.eggState==EggHandler.eggStates.FINALFORM_HEART:
		push_error("Error occured in HomeScript - have transitioned into FInalFormHeart but there is an additional heart")
	
	pass

func FinalHeartPlaced(amount:int):
	EggHandler.TransitionToFinalFormWithHeart()
	state=states.IDLE
	CheckState()

	pass

func OreFinishedSelling(amount:int):
	oresBeingSold-=1
	EggHandler.UpdateSize(EggHandler.oldXP+amount)
	
	if oresBeingSold<=0:
		await get_tree().create_timer(1).timeout
		state=states.IDLE
		CheckState()
	
	pass

func HatchEgg():
	MusicPlayer.shouldPlayMusic=false
	Player.hide()
	
	EggHandler.SetEggState(EggHandler.eggStates.FINALCUTSCENE)
	state=states.FINALCUTSCENE
	Camera.StartNewLerp(CameraLerpPosition.position, 0.5)
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.SHOP
	
	
	pass

func EggFinishedHatching():
	HUD.SetSceneState(HUD.sceneStates.CREDITS)

	
	

func MainMenu_SetupSleepIdle():
	
	Camera.StartNewLerp(CameraLerpPosition.global_position,0)
	EggHandler.SetBirdyVisible(true)
	animSleep.animation="asleep"
	animSleep.play()
	animSleep.show()
	
func _on_interact_button_end_day_button_progress_changed(progress: bool) -> void:
	if !progress:
		MusicPlayer.SetState(hub_music_player.musicStates.IDLE)
	else:
		MusicPlayer.SetState(hub_music_player.musicStates.DREAM)
	
	pass # Replace with function body.

func GoToBed():
	MusicPlayer.SetState(hub_music_player.musicStates.DREAM)

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

func WakeUp(saveGame:bool,progressDay:bool=true):
	
	if saveGame:
		$"..".SaveGame()
		
		if progressDay: #assumption: we never wanna not save but still progress day
			GlobalVariables.currentDay+=1
	justWokeUp=true
	MusicPlayer.UpdateIdleMusic()
	MusicPlayer.SetState(hub_music_player.musicStates.IDLE)
	$Eggs/BirdySleepPositions/birdySleep/ZZZ.emitting=false
	
	
	Camera.SetFollowPlayer(true)
	Player.position=$PlayerWakeupPos.position
	Player.show()
	animSleep.hide()
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.DIG
	
	state=states.IDLE
	SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_WAKEUP)
	
func ReplendishStats():
	LightHandler.RefillLight()
	HealthHandler.RefillHealth()
	pass
	
func Respawn():
	ReplendishStats()
	WakeUp(true)#temporary - will do a custom one later
	
	#Sometimes the player will take damage upon respawning if the source of dmg is present where they died. This shoooould solve that - moving the player b4 telling it everything is normal
	await get_tree().create_timer(0.05).timeout
	Player.state=Player.States.IDLE
	
	pass
	
func IsPlayerInCollider():
	return $NestCollider.get_overlapping_bodies().size()>0
	
	pass

func PlayLayEggCutscene():
	GlobalVariables.playerStatus=GlobalVariables.playerStatusEnum.SHOP
	Player.hide()
	Player.StopWalkSound()
	
	nestCutscene.Play()
	nestCutscene.CutsceneComplete.connect(EggCutsceneFinished)
	
func EggCutsceneFinished():
	state=states.SLEEP
	UpdateButtons()
	EggHandler.SetEggState(EggHandler.eggStates.GROWING)
	EggHandler.UpdateSizeBasedOnSaveData()
	
	animSleep.show()
	animSleep.animation="asleep"
	animSleep.play()
	
	await get_tree().create_timer(6).timeout
	WakeUp(true,false)
	
	pass

func _on_nest_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if EggHandler.eggState==EggHandler.eggStates.NOTHING and !GlobalVariables.InitialSetup:
		return

	
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
		$Eggs/BirdySleepPositions/birdySleep/ZZZ.emitting=true
	pass # Replace with function body.


func _on_cutscene_timer_timeout() -> void:
	Shop.SetActive(true)
	ReplendishStats()
	pass # Replace with function body.


func _on_shop_handler_shop_closed() -> void:
	WakeUp(true)	
	pass # Replace with function body.


func _on_egg_cutscene_trigger_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if EggHandler.eggState==EggHandler.eggStates.NOTHING and !GlobalVariables.InitialSetup:
		PlayLayEggCutscene()
		return
	
	pass # Replace with function body.
