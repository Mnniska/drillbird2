extends Node2D

class_name demo_timer

var currentTime:float=0
@export var timeBeforeReset:float=15
@onready var hud=$".."
@onready var warning:RichTextLabel=$warning

var shouldCount:bool=false

func _ready():
	hud.menuStateChanged.connect(menuChanged)

func menuChanged(state:HUD.menuStates):
	
	#{MAIN,PAUSE,OPTIONS,PLAY,CREDITS}
	
	match state:
		HUD.menuStates.MAIN:
			shouldCount=false
		HUD.menuStates.PLAY:
			shouldCount=true
		HUD.menuStates.PAUSE:
			shouldCount=false
	
	pass

func _process(delta: float) -> void:
	if !shouldCount:
		currentTime=0
		warning.hide()
		return
	
	currentTime+=delta
	
	if timeBeforeReset-currentTime<10:
		warning.show()
		var timeleft=timeBeforeReset-currentTime
		var n="n"
		if timeleft<1.5:
			n=""
		warning.text="[center]Zurücksetzen in "+ str(round(timeleft))+ " Sekunde"+n
	else:
		warning.hide()
	
	if currentTime>timeBeforeReset:
		hud.ResetGame()
		currentTime=0

func _input(event: InputEvent) -> void:
	currentTime=0
