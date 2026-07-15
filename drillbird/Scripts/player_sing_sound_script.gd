extends AudioStreamPlayer2D
class_name singing_script
var currentPitch:float=1
var targetPitch:float=1
var singDirection:player_script.singingDirectionEnum
var isSinging:bool=false



func StartSinging():
	isSinging=true
	await get_tree().create_timer(0.1).timeout
	if isSinging:
		self.play()
	pass

func StopSinging():
	isSinging=false
	self.stop()
	pass
	

func UpdateSingDirection(dir:player_script.singingDirectionEnum):
	
	match dir:
		player_script.singingDirectionEnum.neutral:
			targetPitch=1
		player_script.singingDirectionEnum.left:
			targetPitch=0.9
		player_script.singingDirectionEnum.up:
			targetPitch=1.2
		player_script.singingDirectionEnum.right:
			targetPitch=1.1
		player_script.singingDirectionEnum.down:
			targetPitch=0.8

func _process(delta: float) -> void:
	if !isSinging:
		return
	
	currentPitch=lerpf(currentPitch,targetPitch,delta*5)
	
	self.pitch_scale=currentPitch


func _on_finished() -> void:
	if isSinging:
		self.play()
	
	pass # Replace with function body.
