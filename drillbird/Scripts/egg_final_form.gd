extends Node2D
class_name egg_final_form
signal signal_hatching_complete

var isActive:bool=false
var isShaking:bool=false
var shakeAmount:float=1.8

@onready var animator=$AnimatedSprite2D
@onready var hatchAnimation=$Anim_birds_hatching
@onready var EggOriginalPosition:Vector2=hatchAnimation.position
@onready var useVibration=GlobalVariables.useVibration

enum finalFormStates{FINAL_INACTIVE,FINAL_HEARTLESS,FINAL_HEART,FINAL_HATCHING}
var finalFormState:finalFormStates=finalFormStates.FINAL_HEARTLESS

	
func _process(delta: float) -> void:
	
	if isShaking:
		hatchAnimation.position=EggOriginalPosition+Vector2(randf_range(-shakeAmount,shakeAmount),0)


func GetFinalHeartPosition():
	return $FinalHeartPosition.global_position

func SetState(_state:finalFormStates):
	finalFormState=_state

	match finalFormState:
		finalFormStates.FINAL_INACTIVE:
			hide()
			pass
		finalFormStates.FINAL_HEARTLESS:
			show()
			animator.animation="final_form_idle"

			pass
		finalFormStates.FINAL_HEART:
			animator.animation="final_form_with_heart_idle"

			show()
			pass
		finalFormStates.FINAL_HATCHING:
			HatchEgg()
			show()

			

func HatchEgg():

	useVibration=GlobalVariables.useVibration
	$Anim_hatching_drillbird.animation="wait"
	hatchAnimation.animation="wait"
	animator.animation="hatch"

	isShaking=false
	await get_tree().create_timer(2).timeout

	SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.OUTRO_EGG_HATCH)	

	isShaking=true

	#make controller vibrate while shaking babyyyy
	if useVibration:
		Input.start_joy_vibration(GlobalSymbolRegister.currentController,0.8,0.8,1)	
	await get_tree().create_timer(1).timeout
	isShaking=false
	await get_tree().create_timer(0.5).timeout
	
	isShaking=true
	if useVibration:
		Input.start_joy_vibration(GlobalSymbolRegister.currentController,0.8,0.8,0.5)	
	await get_tree().create_timer(0.5).timeout
	isShaking=false
	await get_tree().create_timer(0.5).timeout

	isShaking=true
	if useVibration:
		Input.start_joy_vibration(GlobalSymbolRegister.currentController,0.8,0.8,1.5)	
	await get_tree().create_timer(1.5).timeout
	isShaking=false
	await get_tree().create_timer(2).timeout

	isShaking=true
	hatchAnimation.animation="hatch"
	hatchAnimation.play()
	$Anim_hatching_drillbird.animation="hatch"
	$Anim_hatching_drillbird.play()
	hatchAnimation.animation_finished.connect(HatchCutsceneFinished)
	
	if useVibration:
		Input.start_joy_vibration(GlobalSymbolRegister.currentController,0.8,0.8,1)	
	await get_tree().create_timer(1).timeout
	isShaking=false
	await get_tree().create_timer(1.3).timeout
	HUD.SpeedrunTimer.finishSpeedrun()
	
	#handled here because the timer stops here
	if HUD.SpeedrunTimer.time< SteamHandler.stat_ach_speed_fastest:
		SteamHandler.TryUnlockAchievement("ach_speed_fastest")

	
func HatchCutsceneFinished():
	var camera:game_camera=GlobalVariables.MainSceneReferenceConnector.camera
	camera.StartNewLerp(camera.position+Vector2(0,-200),2,3)
	await get_tree().create_timer(2).timeout
	signal_hatching_complete.emit()
	pass

func TransitionToFinalForm():

	isShaking=true
	animator.animation="go_to_final_form"
	animator.play()
	await get_tree().create_timer(2).timeout
	isShaking=false
	await get_tree().create_timer(2).timeout
	animator.animation="final_form_idle"
	
	pass

func RecieveHeartCutscene():
	finalFormState=finalFormStates.FINAL_HEART
	animator.animation="final_form_with_heart_idle"
	animator.play()
	pass
