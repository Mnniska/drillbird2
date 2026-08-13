extends Node2D

@onready var anim=$animator
@export var timeToRecharge:float=3
var rechargeCounter:float=0

var active:bool=true
enum States{active,breaking,broken,reassembling}
var currentState:States=States.active

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !active:
		rechargeCounter+=delta
		if rechargeCounter>=timeToRecharge:
			rechargeCounter=0
			RespawnCrystal()
	
func RespawnCrystal():
	anim.play("reassemble")
	await anim.animation_finished
	SetActive(true)
	rechargeCounter=0

func SetActive(_active:bool):
	
	active=_active
	
	if active:
		anim.show()
		anim.play("idle")
		
func BreakCrystal():
	active=false
	anim.play("break")
	await anim.animation_finished
	anim.play("broken_idle")

func _on_area_2d_player_collider_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if !active:
		return
	
	
	if body.name=="Player":
		body.RechargeCrystalActivated()
		BreakCrystal()
	
	
	pass # Replace with function body.
