extends Node2D
signal signal_credits_finished

@onready var scrollparent=$VBoxContainer2
@onready var credits_text:RichTextLabel=$VBoxContainer2/RichTextLabel

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
	scrollSpeed=-14
	scrollparent.position.y= creditsStartPos.position.y
	

func StartScrolling():
	TranslateCredits()
	scrollSpeed=-14
	scrollparent.position.y= creditsStartPos.position.y
	active=true
	creditsDone=false


func TranslateCredits():
	credits_text.text=tr("credits_all_of_it_lol")


func _physics_process(delta: float) -> void:
	

	
	if !active:
		return
		
	if Input.is_action_pressed("drill") or Input.is_action_pressed("interact"):
		scrollSpeed=maxScrollSpeed
	else:
		scrollSpeed=defaultScrollSpeed
	
	
	scrollparent.position.y-=scrollSpeed*delta
	
	if !creditsDone:
		if GetAreCreditsDone():	
			creditsDone=true
			signal_credits_finished.emit()
			

func GetAreCreditsDone()->bool:
	return $"VBoxContainer2/Credits end".global_position.y<$CenterOfScreen.global_position.y
