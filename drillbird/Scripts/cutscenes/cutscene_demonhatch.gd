extends Node2D

@onready var anim_demon:AnimatedSprite2D=$Demonchild
@onready var anim_egg:AnimatedSprite2D=$egg


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if Input.is_action_just_pressed("sing"):
		PlayBadEnding()
	
	pass

func PlayBadEnding():
	
	anim_egg.play("crack")
	
	await get_tree().create_timer(2.4).timeout
	
	anim_demon.play("hatch")
	
	
	
	pass
	
