extends Node2D
class_name cutscene_cursed_mode_hatch
@onready var anim_BadEnding:AnimatedSprite2D=$Demonchild
@onready var anim_TrueEnding:AnimatedSprite2D=$"True Ending"
@onready var anim_egg:AnimatedSprite2D=$egg
signal FinishedCutscene

var originalEggPosition:Vector2
var isShaking:bool=false
var shakeAmount:float=1.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	originalEggPosition=anim_egg.position
	
	pass # Replace with function body.

func _physics_process(delta: float) -> void:	
	
	if isShaking:
		anim_egg.position=originalEggPosition+Vector2(randf_range(-shakeAmount,shakeAmount),0)
	
	pass

func GetDemonEgg()->Node2D:
	return anim_egg

func PrepareHatching():
	anim_egg.play("waiting")
	anim_BadEnding.play("waiting")

func PlayGoodEnding():
	anim_egg.play("crack")
	anim_BadEnding.stop()
	await get_tree().create_timer(2.4).timeout
	
	anim_TrueEnding.play("hatch")
	await anim_TrueEnding.animation_finished
	await get_tree().create_timer(2).timeout
	
	FinishedCutscene.emit()
	

func PlayBadEnding():
	
	anim_egg.play("crack")
	
	await get_tree().create_timer(2.4).timeout
	
	anim_BadEnding.play("hatch")
	
	await anim_BadEnding.animation_finished
	await get_tree().create_timer(2).timeout
	
	FinishedCutscene.emit()
	
	
	
	pass
	
