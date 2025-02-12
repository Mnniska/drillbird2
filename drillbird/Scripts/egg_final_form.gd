extends Node2D
class_name egg_final_form
var isActive:bool=false
var isShaking:bool=false
var shakeAmount:float=2
@onready var originalPosition:Vector2=self.position
@onready var animator=$AnimatedSprite2D

enum finalFormStates{FINAL_INACTIVE,FINAL_HEARTLESS,FINAL_HEART,FINAL_HATCHING}
var finalFormState:finalFormStates=finalFormStates.FINAL_HEARTLESS

func _ready() -> void:
	SetActive(true)
	
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
			show()
			pass
			
func SetActive(active:bool):
	isActive=active
	
	if isActive:
		show()
		animator.animation="final_form_idle"
	else:
		hide()

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
