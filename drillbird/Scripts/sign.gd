extends Node2D

@onready var collider=$Area2D_show_sign
@onready var sign = $Sign
var playerInArea:bool=false
var readingSignCounter:float=0
var sign_activation_time=0.1

var showing_sign:bool=false

func _process(delta: float) -> void:
	
	#The reason for the timer is that the player switches active collider depending on if they're airborne or not - so the layer will flicker on/off. 
	#By adding a short delay b4 sign shows, I ensure the collision registers without flickering
	if playerInArea:
		readingSignCounter=max(sign_activation_time,readingSignCounter+delta)
	else:
		readingSignCounter=min(0,readingSignCounter-delta) 
	
	if readingSignCounter>sign_activation_time:
		SetSignVisible(true)
	
	if readingSignCounter<=0:
		SetSignVisible(false)
		

func SetSignVisible(visible:bool):
	
	if visible==showing_sign:
		return
	else:
		showing_sign=visible
	
	if showing_sign:
		sign.show()
	else:
		sign.hide()
	

func _on_area_2d_show_sign_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	SetSignVisible(true)
	
	playerInArea=true
	pass # Replace with function body.


func _on_area_2d_show_sign_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	SetSignVisible(false)
	playerInArea=false
	pass # Replace with function body.
