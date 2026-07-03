extends Node2D
@onready var slimeballReference=preload("res://Scenes/Effects/slimeball.tscn")
@onready var animator=$AnimatedSprite2D
@onready var slimeballSpawnpos=$slimeballSpawnPos

var isDropping:bool=false
var active:bool=true
var timeBeforeDrop:float=0
var timeBeforeDropCounter:float=2

@export var minTimeBeforeDrop:float=1
@export var maxTimeBeforeDrop:float=5

func _process(delta: float) -> void:
	if !active or isDropping:
		return
	
	timeBeforeDropCounter+=delta
	if timeBeforeDropCounter>timeBeforeDrop:
		Drop()

func Drop():
	if isDropping:
		return
	else:
		isDropping=true
		
	animator.play("drop_prepare")
	await animator.animation_finished
	animator.play("drop_drop")
	#spawn drop
	
	var node:Node2D=slimeballReference.instantiate()
	add_child(node)
	node.position=slimeballSpawnpos.position
	
	await animator.animation_finished
	animator.play("idle")
	
	timeBeforeDrop=randf_range(minTimeBeforeDrop,maxTimeBeforeDrop)
	isDropping=false

func SetActive(_active:bool):
	active=_active
