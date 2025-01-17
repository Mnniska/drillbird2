extends Node2D
enum typeEnum {FADE,GOTOPOS,STAY}
var behavior:typeEnum = typeEnum.FADE
@onready var textObject=$RichTextLabel

@export var texteffects:Array[abstract_textEffect]
var effect:abstract_textEffect
var centerB="[center]"
var centerE="[/center]"
var textToShow=""


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Setup(_txt:String,_effectType:abstract_textEffect.effectEnum):
	textToShow=_txt
	effect=texteffects[_effectType]
		
	textObject.text=centerB+effect.beginEffect+textToShow+effect.endEffect+centerE
	
	TypeWriteText()
	pass

func TypeWriteText():
	
	var displayedText:int=0
	for n in textToShow:
		displayedText+=1
		textObject.visible_characters=displayedText
		await get_tree().create_timer(0.05).timeout
		pass
	
	if behavior==typeEnum.FADE:
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
