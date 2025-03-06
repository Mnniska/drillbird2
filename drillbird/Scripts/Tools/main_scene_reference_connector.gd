extends Node
class_name main_scene_reference_connector

@onready var mainScene=$".."
@onready var player=$"../Player"
@onready var playerDarkness=$"../PlayerDarkness"
@onready var ref_home=$"../Home"
@onready var ref_camera=$"../Camera2D"
@onready var ref_oreTilemap=$"../TilemapOres"
@onready var camera=$"../Camera2D"
@onready var introCutscene=$"../IntroCutscene"



func _ready() -> void:
	GlobalVariables.MainSceneReferenceConnector=self
