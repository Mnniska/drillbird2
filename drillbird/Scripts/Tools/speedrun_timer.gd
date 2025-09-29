extends Node
class_name speedrun_timer

var time:float=0
@onready var timerText:RichTextLabel=$"timer text"
var shouldUpdateTimerText:bool=false
var timePaused:bool=false


func _physics_process(delta: float) -> void:
	if timePaused:
		return
	
	time+=delta
	
	if shouldUpdateTimerText:
		if timerText!=null:
			timerText.text="[right]"+GetTimerString(time)

			

func GetTimerString(calcTime:float)->String:
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
	shouldUpdateTimerText=!shouldUpdateTimerText
	if shouldUpdateTimerText:
		timerText.show()
	else:
		timerText.hide()

func SetTimerEnabled(enabled:bool):
	shouldUpdateTimerText=enabled
	if shouldUpdateTimerText:
		timerText.show()
	else:
		timerText.hide()
	
func SetTimerPaused(pause:bool):
	timePaused=pause
