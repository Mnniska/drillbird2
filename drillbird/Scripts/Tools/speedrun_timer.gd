extends Node
class_name speedrun_timer

var time:float=0
@onready var timerText:RichTextLabel=$"timer text"
var showTimer:bool=false
var timePaused:bool=false
var speedrunFinished:bool=false

func _ready() -> void:
	HUD.signal_menuStateChanged.connect(MenuStateChanged)

func MenuStateChanged(state: HUD.menuStates):
	timePaused=true
	
	#assumption: PLAY is the only state where the timer should be paused. This requires pausing to not give any time benefits..
	if state==HUD.menuStates.PLAY:
			timePaused=false
	
	match state:
		HUD.menuStates.MAIN:
			timerText.hide()
		HUD.menuStates.CREDITS:
			pass
		HUD.menuStates.PLAY:
			if showTimer:
				timerText.show()
			else:
				timerText.hide()
			
	
	pass

func _physics_process(delta: float) -> void:
	if timePaused or speedrunFinished:
		return
		
	if Input.is_physical_key_pressed(KEY_0):
		finishSpeedrun()
	
	time+=delta
	
	if showTimer:
		if timerText!=null:
			timerText.text="[right]"+GetTimerString(time)

			

#called from the egg hatch cutscene in HOME
func finishSpeedrun():
	if speedrunFinished:
		return
	speedrunFinished=true
	
	var numbertext=timerText.text
	
	for e in 10:
		timerText.text="[color=orange][right]"+numbertext
		await get_tree().create_timer(0.2).timeout
		timerText.text="[color=white][right]"+numbertext
		await get_tree().create_timer(0.2).timeout
	
	await get_tree().create_timer(2).timeout
	timerText.hide()

func GetTimerString(calcTime:float=time)->String:
	var temptime=calcTime
	
	var minutes:int=00
	var seconds:int=00
	var tenths:float=00
	
	minutes = floor(time/60)
	if minutes > 0:
		temptime-=minutes*60
	
	seconds = floor(temptime)
	
	if seconds >0:
		temptime-=seconds
	
	tenths= snapped(temptime, 0.1) # => 1.1

	var minuteZeros="00"
	if minutes<10:
		minuteZeros="0"
	else:
		minuteZeros=""
	
	var secondZeros="00"
	if seconds<10:
		secondZeros="0"
	else:
		secondZeros=""
	
	if tenths==1:
		tenths=0
	
	return minuteZeros+str(minutes)+":"+secondZeros+str(seconds)+":"+str(tenths*10)
	
pass

#used when loading an old game
func SetCurrentTime(_time:float):
	time=_time

func GetCurrentTime():
	return time

func ToggleTimerTextEnabled():
	SetShowTimer(!showTimer)


func SetShowTimer(enabled:bool):
	showTimer=enabled
	if showTimer:
		timerText.show()
	else:
		timerText.hide()
	
func SetTimerPaused(pause:bool):
	timePaused=pause
