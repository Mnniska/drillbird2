extends Node2D
@export var stringToShowID:String="default"

@onready var text=$Sign/VBoxContainer/PanelContainer/MarginContainer/text_sign
@onready var collider=$Area2D_show_sign
@onready var sign = $Sign
@onready var animationplayer=$AnimationPlayer
var playerInArea:bool=false


var showing_sign:bool=false
var busy:bool=false

var signshowfloat:float=0
var timeToAppear:float=1.5
var signAnimshouldPlay:bool=false
var sign_has_been_read:bool=false


func _ready() -> void:
	sign.modulate=Color(Color.WHITE,signshowfloat) 

func _process(delta: float) -> void:
	
	#The reason for the timer is that the player switches active collider depending on if they're airborne or not - so the layer will flicker on/off. 
	#By adding a short delay b4 sign shows, I ensure the collision registers without flickering
	if playerInArea:
		signshowfloat=min(1,signshowfloat+delta)
		
		if !signAnimshouldPlay:
			animationplayer.play("appear")
		signAnimshouldPlay=true
		$exclamation_mark.hide()
		
	else:
		signshowfloat=max(0,signshowfloat-delta*2)
	
	if signshowfloat<=0:
		signAnimshouldPlay=false
	sign.modulate=Color(Color.WHITE,signshowfloat) 
		



func _on_area_2d_show_sign_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	text.text=tr("demo_sign")
	playerInArea=true
	pass # Replace with function body.


func _on_area_2d_show_sign_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:

	playerInArea=false
	pass # Replace with function body.
