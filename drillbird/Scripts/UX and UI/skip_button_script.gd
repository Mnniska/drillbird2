extends PanelContainer
var active:bool=false
var isPressed:bool=false
@export var timeToActivateSkip:float=1
var skipTimeCounter:float=0
@onready var progressBar=$ProgressBar
@onready var textObject=$text

signal SkipButtonPressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SetActive(false)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if active:
		if Input.is_action_pressed("sing"):
			skipTimeCounter=min(timeToActivateSkip,skipTimeCounter+delta)
		else:
			skipTimeCounter=max(0,skipTimeCounter-delta)
			
		var progress=skipTimeCounter/timeToActivateSkip
		progressBar.value=100*progress
		
		if skipTimeCounter>=timeToActivateSkip:
			GlobalVariables.PlayerPressedSkipButton.emit()
			SetActive(false)
			
	
	pass

func SetActive(_active:bool):
	active=_active
	skipTimeCounter=0
	if active:
		show()
	else:
		hide()
	pass
