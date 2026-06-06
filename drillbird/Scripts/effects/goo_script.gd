extends Node2D
class_name goo_egg_animator
enum gooStates{no,big,waitingForHeart}
@onready var currentState:gooStates=gooStates.no
@onready var animator=$anim

@export var minGooWaitTime:float=1
@export var maxGooWaitTime:float=5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func finishedGooAnim():
	if currentState==gooStates.no:
		return
		
	var randomTime=randf_range(minGooWaitTime,maxGooWaitTime)
	await get_tree().create_timer(randomTime).timeout
	
	if currentState==gooStates.big:
		animator.play("goo")
	
	if currentState==gooStates.waitingForHeart:
		var rand2=randf()
		if rand2>=0.5:
			animator.play("heartgoo")
		else:
			animator.play("goo")
		
	
	pass

func SetGooState(state:gooStates):
	if state==currentState:
		return
	
	currentState=state
	match currentState:
		gooStates.big:
			animator.play("goo")
		
		gooStates.waitingForHeart:
			animator.stop()
			await get_tree().create_timer(4).timeout
			animator.play("heartgoo")
	
		gooStates.no:
			hide()
			animator.stop()
			
	if currentState!=gooStates.no:
		animator.show()
		animator.animation_finished.connect(finishedGooAnim)		
	pass
