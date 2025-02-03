extends text_bubble
class_name text_bubble_xp
signal fadedOut

var textTimer:float=0
@export var timeBeforeFadeout:float=2
var isShowingText:bool=false

func ShowText(_txt:String):
	alpha=1
	textToShow=_txt
	textObject.text=centerB+effect.beginEffect+textToShow+effect.endEffect+centerE
	textObject.self_modulate=(Color(1,1,1,1))
	textTimer=0
	
	isShowingText=true
	
	pass
	
func _process(delta: float) -> void:
	if isShowingText:
		textTimer+=delta
		if textTimer>timeBeforeFadeout:
			FadeOut()
			isShowingText=false
	
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
	
	fadedOut.emit()
