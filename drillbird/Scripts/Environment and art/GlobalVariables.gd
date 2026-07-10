extends Area2D


func _on_body_entered(body: Node2D) -> void:
	GlobalVariables.MainSceneReferenceConnector.ref_backgroundHandler.SetIsInFrontshowingArea(true)
	pass # Replace with function body.


func _on_body_exited(body: Node2D) -> void:
	GlobalVariables.MainSceneReferenceConnector.ref_backgroundHandler.SetIsInFrontshowingArea(false)

	pass # Replace with function body.
