extends Node2D
class_name heart_script


enum states {EMPTY,FULL,LASTFULL,AVAILABLE,LIGHTHEART}
var state=states.EMPTY
var full:bool=true
@onready var animator=$HealthAnimation

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func GetStateEnum():
	return states

func TakeDamage():
	if full or state==states.LIGHTHEART:
		SetState(states.EMPTY)
		full=false
		return true
	else:
		return false

func RefillHeart():
	SetState(states.FULL)
	full=true

func SetIsLastHeart(isLightHeart:bool=false):
	
	if isLightHeart:
		SetState(states.LIGHTHEART)
	else:
		SetState(states.LASTFULL)

func SetState(_state:states):
	state=_state
	var anim="empty"
	match state:
		states.EMPTY:
			anim="empty"
			
		states.FULL:
			anim="full"
			
		states.LASTFULL:
			anim="full_last"
			
		states.AVAILABLE:
			anim="available"
		states.LIGHTHEART:
			anim="lightheart"
	
	animator.animation=anim
	animator.play()
	
	pass
