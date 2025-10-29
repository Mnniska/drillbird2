extends Node2D

@onready var bitscene=preload("res://Scenes/eggsplosion/egg_part.tscn")

var bits: Array[eggpart]

func _ready() -> void:
	
	for n in bits:
		n.queue_free()
		
	Boom()

#todo - make this sick

func Boom(amount:int=20):
	
	for n in amount:
	
		var shell:eggpart = bitscene.instantiate()
		
		add_child(shell)
		bits.append(shell)
		
		var x=150
		var ymin =-100
		var ymax=-250
		
		var impulse = Vector2(randf_range(-x,x), randf_range(ymin,ymax))
		
		shell.apply_central_impulse(impulse)
		shell.rotation_degrees=randf_range(0,360)
		shell.apply_torque_impulse(randf_range(-x,x))
	
