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
var textColor:Color=Color.WHITE



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if MoveUp:
		global_position+=Vector2(0,-10*delta)
	
	pass

func ShowText(_txt:String,timeBeforeFade:float=0.2):
	textObject.text=""
	textToShow=""
	alpha=1	
	
	textToShow=GlobalSymbolRegister.GetStringDecoded(tr(_txt))
			
	textObject.text=centerB+effect.beginEffect+textToShow+effect.endEffect+centerE
	textObject.modulate=textColor

	TypeWriteText(timeBeforeFade)
	

func Setup(_effectType:abstract_textEffect.effectEnum=abstract_textEffect.effectEnum.STILL,_behaviour:behaviourEnum=behaviourEnum.FADE,col:Color=Color.WHITE):

	behavior=_behaviour
	effect=texteffects[_effectType]
	textColor=col
	
	pass

func TypeWriteText(timeBeforeFade:float=0.2):
	
	
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
		await get_tree().create_timer(timeBeforeFade).timeout
		FadeOut()
	
	pass
	
func FadeOut():
	
	alpha=1
	var step=0.1
	
	
	while alpha>0:
		textColor.a=5
		textObject.self_modulate=(Color(textColor.r,textColor.g,textColor.b,alpha))
		alpha-=step
		await get_tree().create_timer(0.1).timeout

	if DestroyAfterFadingOut:
		queue_free()
	
