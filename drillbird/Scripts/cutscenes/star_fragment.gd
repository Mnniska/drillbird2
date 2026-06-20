extends Node2D
class_name star_fragment
@onready var anim = $AnimatedSprite2D

@export var worth:float=20
@export var speedMax:float=100
@export var speedMin=50
var speed=0
var dead:bool=false

var idle_animation="idle"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	speed=randf_range(speedMax,speedMin)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	position.x-=speed*delta
	
	if position.x<-500:
		queue_free()
	
	pass

func SetScared(scared:bool):
	if scared:
		idle_animation="idle_scared"
	else:
		idle_animation="idle"

	
	pass

func DestroySelfAfterAnimation():
	dead=true
	anim.animation="collect"
	SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.HOME_GIVEORE_POFF)
	anim.play("collect")
	speed=speed*0.2
	await anim.animation_finished
	queue_free()	
