extends Node
class_name main_scene_reference_connector

@onready var mainScene=$".."
@onready var player=$"../Player"
@onready var playerDarkness=$"../PlayerDarkness"
@onready var ref_home=$"../Home"
@onready var ref_camera=$"../Camera2D"

@onready var camera=$"../Camera2D"
@onready var introCutscene=$"../IntroCutscene"
@onready var shop:script_shop=$"../Camera2D/ShopHandler"
@onready var ref_WorldSpawner=$"../WorldSpawner"
@onready var ref_tileDestroyer=$"../TileCrack"
var ref_secretTilemap
var ref_oreTilemap
var ref_environmentTilemap



func _ready() -> void:
	GlobalVariables.MainSceneReferenceConnector=self
	GlobalVariables.WorldHasBeenSpawned.connect(SetupSpawnedWorldReferences)

func SetupSpawnedWorldReferences():
	ref_secretTilemap=$"../WorldSpawn/TileMap_secrets"
	ref_oreTilemap=$"../WorldSpawn/TilemapOres"
	ref_environmentTilemap=$"../WorldSpawn/TilemapEnvironment"
	
	pass
