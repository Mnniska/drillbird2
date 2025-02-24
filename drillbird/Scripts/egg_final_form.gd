extends Node2D
class_name egg_final_form
signal signal_hatching_complete

var isActive:bool=false
var isShaking:bool=false
var shakeAmount:float=2
@onready var originalPosition:Vector2=self.position
@onready var animator=$AnimatedSprite2D
@onready var anim_birds=$Anim_birds_hatching

enum finalFormStates{FINAL_INACTIVE,FINAL_HEARTLESS,FINAL_HEART,FINAL_HATCHING}
var finalFormState:finalFormStates=finalFormStates.FINAL_HEARTLESS

	
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_tab"):
		TransitionToFinalForm()
	
	if isShaking:
		position=originalPosition+Vector2(randf_range(-shakeAmount,shakeAmount),0)

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
	isShaking=true
	animator.animation="hatch"
	await get_tree().create_timer(2).timeout
	isShaking=false
	await get_tree().create_timer(3).timeout

	anim_birds.animation="hatch"
	anim_birds.play()
	anim_birds.animation_finished.connect(HatchCutsceneFinished)

	
func HatchCutsceneFinished():
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
	#TODO: Final form with heart transition
	finalFormState=finalFormStates.FINAL_HEART
	animator.animation="final_form_with_heart_idle"
	animator.play()
	pass
