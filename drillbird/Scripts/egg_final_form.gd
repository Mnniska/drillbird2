extends Node2D

var isActive:bool=false
var isShaking:bool=false
var shakeAmount:float=2
@onready var originalPosition:Vector2=self.position
@onready var animator=$AnimatedSprite2D

func _ready() -> void:
	SetActive(true)
	
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("debug_tab"):
		TransitionToFinalForm()
	
	if isShaking:
		position=originalPosition+Vector2(randf_range(-shakeAmount,shakeAmount),0)

func SetActive(active:bool):
	isActive=active
	
	if isActive:
		show()
		animator.animation="before_final_form"
	else:
		hide()

func TransitionToFinalForm():
	
	isShaking=true
	animator.animation="go_to_final_form"
	animator.play()
	await get_tree().create_timer(1.5).timeout
	isShaking=false
	await get_tree().create_timer(2).timeout
	animator.animation="final_form_idle"
	
	pass

func ActivateFinalCutscene():
	
	pass
