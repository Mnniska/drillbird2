extends Node2D
@onready var text:RichTextLabel=$RichTextLabel
@onready var creditsFile=FileAccess.open("res://Resources/credits.txt", FileAccess.READ)

var textShowTimeDefault:float=0.02
var textShowTime:float=textShowTimeDefault
var linePauseTime:float=2
var textShowCounter:float=0

var currentLine=0


var scrollSpeed:float=0
var scrollAcc:float=0.03
var maxScrollSpeed:float=80

@onready var creditsStartPos=$StartPos


func _ready() -> void:
	#text.text=creditsFile.get_as_text()
	scrollSpeed=-14
	text.position=creditsStartPos.position

func _physics_process(delta: float) -> void:
	
	if Input.is_action_pressed("up"):
		scrollSpeed-=scrollAcc
	if Input.is_action_pressed("down"):
		scrollSpeed+=scrollAcc

	scrollSpeed=clampf(scrollSpeed,-maxScrollSpeed,maxScrollSpeed)
	
	text.position.y+=scrollSpeed*delta

			

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
