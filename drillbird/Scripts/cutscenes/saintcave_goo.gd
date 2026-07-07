extends Node2D
@onready var animator = $"floor goo and grave"
@export var amountOfAnims:int=8
# Called when the node enters the scene tree for the first time.


func UpdateGooProgress():
	
	var progress:float=float(GlobalVariables.currentDay) / float(GlobalVariables.daysBeforeDemonKillsEgg+1) #adding 1 here because u can still save the saint on the FINAL day
	
	progress=min(progress,1)
	#create a progress number based on progress towards saint being killed
	var value:int = floor(progress*amountOfAnims)
	
	var eh="one"
	match value:
		2: eh="two"
		3: eh="three"
		4: eh="four"
		5: eh="five"
		6: eh="six"
		7:eh="seven"
		8:eh="final"
			
	
	animator.play(eh)
	
	
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	UpdateGooProgress()
