extends Node2D
class_name text_bubble

enum behaviourEnum {FADE,GOTOPOS,STAY}
var behavior:behaviourEnum = behaviourEnum.FADE
@onready var textObject:RichTextLabel=$RichTextLabel

@export var texteffects:Array[abstract_textEffect]

var effect:abstract_textEffect
var centerB="[center]"
var centerE="[/center]"
@export var textToShow:String="defaultText"
var DestroyAfterFadingOut:bool=true
var UseTypewriteEffect:bool=true
var MoveUp:bool=false
var alpha=1



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if MoveUp:
		global_position+=Vector2(0,-10*delta)
	
	pass

func ShowText(_txt:String):
	textObject.text=""
	textToShow=""
	alpha=1	
	
	var symbolName:String=""
	#parses through [symbols] and replaces them wqith appropiate image links
	for _char in _txt:
		
		if _char =='[' or symbolName.length()>0:
			symbolName+=_char
			if _char==']':
#				textToShow+=global_symbol_register
				textToShow+="[img]"+GlobalSymbolRegister.GetSymbolFromString(symbolName)+"[/img]"

				symbolName=""
		else:
			textToShow+=_char
			
	textObject.text=centerB+effect.beginEffect+textToShow+effect.endEffect+centerE
	textObject.self_modulate=(Color(1,1,1,1))
	TypeWriteText()
	

func Setup(_effectType:abstract_textEffect.effectEnum,_behaviour:behaviourEnum):

	behavior=_behaviour
	effect=texteffects[_effectType]
	
	pass

func TypeWriteText():
	
	
	var displayedText:int=0
	for n in textToShow:
		
		
		displayedText+=1
		if !UseTypewriteEffect:
			textObject.visible_characters=-1
		else:
			textObject.visible_characters=displayedText
		await get_tree().create_timer(0.05).timeout
		pass
	
	if behavior==behaviourEnum.FADE:
		await get_tree().create_timer(0.2).timeout
		FadeOut()
	
	pass
	
func FadeOut():
	
	alpha=1
	var step=0.1
	
	
	while alpha>0:
		
		textObject.self_modulate=(Color(1,1,1,alpha))
		alpha-=step
		await get_tree().create_timer(0.1).timeout

	if DestroyAfterFadingOut:
		queue_free()
	
