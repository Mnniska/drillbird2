extends Node
@export var SpawnRight:bool=true
@onready var waterpath=preload("res://Scenes/Water shenanigans/WaterPiece.tscn")
var waterSpawned:bool=false
var cooldown:float=0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	cooldown-=delta
	
	if Input.is_physical_key_pressed(KEY_0) and cooldown<=0:
		cooldown=2
		SpawnWater()
	
	if Input.is_physical_key_pressed(KEY_9):
		DeleteWater()

func DeleteWater():
	for child in get_children():
		child.queue_free()

func SpawnWater():
	var water:water_piece = waterpath.instantiate()
	
	add_child(water)
	var dir:water_piece.dir=water_piece.dir.right
	if SpawnRight:
		water.position=Vector2(16,0)
	else:
		water.position=Vector2(-16,0)
		dir=water_piece.dir.left
	
	water.SetupCheck(water.waterType.falling,dir)

	pass
