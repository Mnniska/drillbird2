extends Node2D
var ghostRef
var ghostInScene
var ghostSpawned:bool=false
@onready var player= $"../Player"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.playerLightStatusChange.connect(playerLightStatusChanged)
	ghostRef=preload("res://Scenes/ghost.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	pass
	
	
func playerLightStatusChanged():
	if ghostSpawned && GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.LIT_EXTERNALLY:
		DespawnGhost()
	
	if !ghostSpawned && GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.DARK:
		SpawnGhost()
		#spawn ghost
	
func SpawnGhost():
	ghostSpawned=true
	ghostInScene = ghostRef.instantiate()
	$"..".add_child(ghostInScene)
	ghostInScene.position=global_position
	ghostInScene.NewHaunting(player)
	
	pass

func DespawnGhost():
	ghostInScene.Disappear()
	ghostInScene=null
	ghostSpawned=false