extends Node2D

var starFragmentPath=preload("res://Scenes/Objects and Enemies/star_fragment.tscn")

@onready var line = $Line2D

@export var minTimeBeforeSpawn:float=4
@export var maxTimeBeforeSpawn:float=8
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
		timeBeforeSpawn=randf_range(maxTimeBeforeSpawn,minTimeBeforeSpawn)
		SpawnNewFragment()
	pass

func SpawnNewFragment():
	var node=starFragmentPath.instantiate()
	add_child(node)
	
	var rand=randf_range(0,160)
	var startpos=line.position+Vector2(0,rand)
	node.position=startpos
	
	
