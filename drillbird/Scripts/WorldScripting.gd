extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	GlobalVariables.playerAction.connect(PlayerAction)
	
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func PlayerAction(action:GlobalVariables.playerActions):

	if action==GlobalVariables.playerActions.DROPORE:
		if $Tutorial_DropOres.textShown:
			$Tutorial_DropOres.PassedTest()
	
	if action==GlobalVariables.playerActions.DRILL:
		if $Tutorial_drill.textShown:
			pass
	
	pass


func _on_player_checker_drill_tutorial_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	$Tutorial_drill.PassedTest()
	
	pass # Replace with function body.


func _on_player_checker_jump_tutorial_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	$Tutorial_jump.PassedTest()
	$Tutorial_drill.BeginTimerWhenEntered=true
	
	pass # Replace with function body.
