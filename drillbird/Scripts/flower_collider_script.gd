extends RigidBody2D
@onready var parent=$".."

func GetCollType():
	return parent.GetCollType()

func GetParent():
	return parent
