extends Node2D

var starFragmentPath=preload("res://Scenes/Objects and Enemies/star_fragment.tscn")
var childFragmentPath=preload("res://Scenes/Objects and Enemies/star_fragment_birdEdition.tscn")

@onready var line = $Line2D

@export var minTimeBeforeSpawn:float=4
@export var maxTimeBeforeSpawn:float=8

@export var minTimeBeforeSpawn_CURSED:float=6
@export var maxTimeBeforeSpawn_CURSED:float=10
var timeBeforeSpawn:float=5
var spawnCounter:float=0
var active:bool=false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !active:
		return
		
	spawnCounter+=delta
	if spawnCounter>=timeBeforeSpawn:
		spawnCounter=0
		
		if GlobalVariables.CursedMode:
			timeBeforeSpawn=randf_range(maxTimeBeforeSpawn_CURSED,minTimeBeforeSpawn_CURSED)
		else:
			timeBeforeSpawn=randf_range(maxTimeBeforeSpawn,minTimeBeforeSpawn)
		SpawnNewFragment()
	pass

func SpawnNewFragment():
	
	var node
	if GlobalVariables.CursedMode:
		node=childFragmentPath.instantiate()
	else:
		node=starFragmentPath.instantiate()
	add_child(node)
	
	var rand=randf_range(0,160)
	var startpos=line.position+Vector2(0,rand)
	node.position=startpos
	
	
