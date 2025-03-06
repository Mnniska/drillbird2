extends Node
class_name credits_scene_reference_connector

@onready var ref_credits_parent=$".."

func _ready() -> void:
	GlobalVariables.CreditsSceneReferenceConnector=self
