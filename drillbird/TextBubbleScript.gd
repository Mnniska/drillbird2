extends Node2D
class_name text_bubble

enum behaviourEnum {FADE,GOTOPOS,STAY}
var behavior:behaviourEnum = behaviourEnum.FADE
@onready var textObject=$RichTextLabel

@export var texteffects:Array[abstract_textEffect]

var effect:abstract_textEffect
var centerB="[center]"
var centerE="[/center]"
@export var textToShow:String="defaultText"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func ShowText(_txt:String):
	textToShow=_txt
	textObject.text=centerB+effect.beginEffect+textToShow+effect.endEffect+centerE
	
	TypeWriteText()
	pass

func Setup(_effectType:abstract_textEffect.effectEnum,_behaviour:behaviourEnum):

	behavior=_behaviour
	effect=texteffects[_effectType]
	
	pass

func TypeWriteText():
	
	var displayedText:int=0
	for n in textToShow:
		displayedText+=1
		textObject.visible_characters=displayedText
		await get_tree().create_timer(0.05).timeout
		pass
	
	if behavior==behaviourEnum.FADE:
		await get_tree().create_timer(0.2).timeout
		FadeOut()
	
	pass
	
func FadeOut():
	
	var alpha=1
	var step=0.1
	
	
	while alpha>0:
		
		textObject.self_modulate=(Color(1,1,1,alpha))
		alpha-=step
		get_tree().create_tween()
		await get_tree().create_timer(0.1).timeout

	
	queue_free()
	pass
