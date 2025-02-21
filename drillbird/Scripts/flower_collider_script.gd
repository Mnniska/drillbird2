extends RigidBody2D
@onready var parent=$".."
var isActive:bool=false

func GetCollType():
	return parent.GetCollType()

func GetParent():
	return parent

func SetActive(active:bool):
	
	if active:
		show()
		#TODO: Make a beautiful spawn anim :) 
	else:
		hide()
	isActive=active
		
	pass
