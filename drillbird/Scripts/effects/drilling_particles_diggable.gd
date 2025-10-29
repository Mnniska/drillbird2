extends Node2D
class_name drill_particle_manager

@onready var bitscene=preload("res://Scenes/eggsplosion/egg_part.tscn")
var bits: Array[eggpart]

@export var maxBits=10
@export var minTimeBeforeSpawn=0.1
@export var maxTimeBeforeSpawn=0.3

var isDrilling:bool=false
var bitTimer:float=0
@onready var timeTarget=randf_range(minTimeBeforeSpawn,maxTimeBeforeSpawn)
enum directions{up,right,down,left}
var currentDir:directions=directions.right

var particleColor:Color

func _ready() -> void:
	
	for n in bits:
		n.queue_free()
	
	#lmao does this work? Would be sick
	$"..".signal_IsDrillingTileChanged.connect(SetIsDrilling)
	
func SetCurrentMaterial(terrain: abstract_terrain_info):
	particleColor=terrain.DestroyParticleColor
	pass

func _process(delta: float) -> void:
	if !isDrilling:
		return
	
	bitTimer+=delta
	
	if bitTimer>=timeTarget:
		bitTimer=0
		timeTarget=randf_range(minTimeBeforeSpawn,maxTimeBeforeSpawn)
		SpawnBit(1)

func TileWasDestroyed():
	SpawnBit(6)

func SetIsDrilling(drilling:bool):
	
	if isDrilling!=drilling:
		isDrilling=drilling
	

func GetDirection()->directions:
	
	#calculates the direction of the drill by looking at position of parent lol
	
	#lmao rename if this works
	var parent=self
	
	var dir:directions=directions.right
	
	if parent.position.y>0:
		dir=directions.down
	elif parent.position.y <0:
		dir=directions.up
	
	elif parent.position.x < 0:
		dir=directions.right
	else:
		dir=directions.left
		
	pass
	
	return dir

func SpawnBit(amount:int=20):
	
	for n in amount:
	
		var shell:eggpart = bitscene.instantiate()
		$"../..".get_parent().add_child(shell)
		shell.SetColor(particleColor)
		shell.global_position=self.global_position
		
		bits.append(shell)
		
		currentDir=GetDirection()
		
		var sideForce=150
		var upForceMin =-50
		var upForceMax=-120
		
		var x=0
		var y=0
		
		var mult=3
		
		match currentDir:
			
			directions.up:
				x=randf_range(-sideForce,sideForce)
				y=-upForceMin
			directions.down:
				x=randf_range(-sideForce,sideForce)
				y=randf_range(-upForceMin,upForceMax)*mult
				
			directions.right:
				x=sideForce
				y=randf_range(-upForceMin,upForceMax)
			directions.left:
				x=-sideForce
				y=randf_range(-upForceMin,upForceMax)
			pass
		

		
		var impulse = Vector2(x, y)
		
		shell.apply_central_impulse(impulse)
		shell.rotation_degrees=randf_range(0,360)
		shell.apply_torque_impulse(randf_range(-x,x))
	
