extends Node

#variable that starts at 0 and counts upwards 
var time:float=0


	
func _physics_process(delta: float) -> void:
	time+=delta
