extends Node2D
signal signal_credits_finished

@onready var text:RichTextLabel=$RichTextLabel
@onready var creditsFile=FileAccess.open("res://Resources/credits.txt", FileAccess.READ)

var textShowTimeDefault:float=0.02
var textShowTime:float=textShowTimeDefault
var linePauseTime:float=2
var textShowCounter:float=0

var currentLine=0

var defaultScrollSpeed=15
var scrollSpeed:float=0
var scrollAcc:float=0.1
var maxScrollSpeed:float=80

var active:bool=false
var creditsDone:bool=false

@onready var creditsStartPos=$StartPos


func _ready() -> void:
	#text.text=creditsFile.get_as_text()
	scrollSpeed=-14
	text.position=creditsStartPos.position

func _physics_process(delta: float) -> void:
	
	if !active:
		return
		
	if Input.is_action_pressed("drill") or Input.is_action_pressed("interact"):
		scrollSpeed=maxScrollSpeed
	else:
		scrollSpeed=defaultScrollSpeed
	
	
	text.position.y-=scrollSpeed*delta
	
	if !creditsDone:
		if GetAreCreditsDone():	
			creditsDone=true
			signal_credits_finished.emit()
			

func GetAreCreditsDone()->bool:
	return $RichTextLabel/CreditsEnd.global_position.y<$CenterOfScreen.global_position.y

func DisplayText(delta:float):
	textShowCounter+=delta

	if textShowCounter>textShowTime:
		textShowTime=textShowTimeDefault
		textShowCounter=0
		text.visible_characters+=1
		
		if text.text[text.visible_characters]=="\n":
			pass
		
		var p=text.get_character_line(text.visible_characters)
		print_debug(str(text.visible_characters))
		if p>currentLine:
			currentLine=p
			textShowTime=linePauseTime
	pass
