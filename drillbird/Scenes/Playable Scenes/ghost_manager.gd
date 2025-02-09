extends Node2D
class_name ghost_manager
var ghostRef
var ghostInScene
var ghostSpawned:bool=false
@onready var player= $"../Player"

#ghost spawning variables
@export var minTimeBeforeGhostSpawns:float=0.2
@export var maxTimeBeforeGhostSpawns:float=2
var TimeBeforeGhostComes:float=minTimeBeforeGhostSpawns
var ghostTimeCounter:float=0
var ghostIsComing:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.playerLightStatusChange.connect(playerLightStatusChanged)
	ghostRef=preload("res://Scenes/Objects and Enemies/ghost.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if ghostIsComing:
		ghostTimeCounter+=delta
		if ghostTimeCounter>TimeBeforeGhostComes:
			SpawnGhost()
			ghostIsComing=false
	pass
	
	
func playerLightStatusChanged():
	if GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.LIT_EXTERNALLY:
		ghostIsComing=false
		pass
		#DespawnGhost()
	
	if !ghostSpawned && GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.DARK:
		if !ghostIsComing:
			ghostIsComing=true
			TimeBeforeGhostComes=randf_range(minTimeBeforeGhostSpawns,maxTimeBeforeGhostSpawns)
			
		#spawn ghost
	
func SpawnGhost():
	ghostSpawned=true
	ghostInScene = ghostRef.instantiate()
	$"..".add_child(ghostInScene)
	ghostInScene.position=player.global_position+Vector2(randi_range(-50,50),randi_range(130,200))
	ghostInScene.NewHaunting(player)
	ghostInScene.GiveParentReference(self)
	
	pass

func DespawnGhost():
	ghostInScene=null
	ghostSpawned=false
