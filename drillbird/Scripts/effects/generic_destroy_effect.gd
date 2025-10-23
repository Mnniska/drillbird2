extends AnimatedSprite2D

@export var spriteframes:SpriteFrames
@onready var animPlayer:AnimatedSprite2D=$"."
@export var time_to_wait:float=1.5
signal finished_bye

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if spriteframes!=null:
		animPlayer.sprite_frames=spriteframes

#	animPlayer.animation_finished.connect(AnimFinish)

	animPlayer.play()
	
	#fuck you inconsistent signals I'll call you back myself you bastard
	await get_tree().create_timer(time_to_wait).timeout
	AnimFinish()
	pass # Replace with function body.

func AnimFinish():
	

	finished_bye.emit()
	queue_free()
	pass
