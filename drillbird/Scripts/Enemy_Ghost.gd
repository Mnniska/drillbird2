extends Node2D

var hauntedObject:Node2D
var playerPos:Vector2
@export var MINSPEED:float=2.8
@export var MAXSPEED:float=5
@export var slowestSpeedDist:float=16*3
@export var fastestSpeedDist:float=16*6

#2.8
var  haunting:bool=false
var lastpos:Vector2
@onready var playerCollider=$PlayerChecker

var parent:ghost_manager


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func HauntObject(delta:float):
	var speed=0
	var distanceToPlayer=self.global_position.distance_to(hauntedObject.global_position)
	
	if distanceToPlayer>fastestSpeedDist:
		speed=MAXSPEED
	
	if distanceToPlayer<fastestSpeedDist && distanceToPlayer>slowestSpeedDist:
		var progress=1-(distanceToPlayer-fastestSpeedDist)/(slowestSpeedDist-fastestSpeedDist)
		speed=MINSPEED+((MAXSPEED-MINSPEED)*progress)
	
	if distanceToPlayer<slowestSpeedDist:
		speed=MINSPEED


	var s=speed*delta
	#position=hauntedObject.position
	position.x = move_toward(position.x, hauntedObject.position.x, s)
	position.y = move_toward(position.y, hauntedObject.position.y, s)
	
	if lastpos.x-position.x<0:
		$sprite.flip_h=true
	else:
		$sprite.flip_h=false
	
	lastpos=Vector2(position.x,position.y)
	#var progress:Vector2=Vector2.from_angle()
	
	#self.position=lerp(position,hauntedObject.position,1)

	pass

func CheckOverlappingCollisions():
	for n in playerCollider.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(1)
		pass
	
	pass

func DealDamage(amount:int):
	
	pass

func GiveParentReference(_parent:ghost_manager):
	parent = _parent
	pass

func Disappear():
	parent.DespawnGhost()
	queue_free()

func NewHaunting(object:Node2D):
	hauntedObject=object
	haunting=true

func lerp(a,b,t):
	return (1 - t) * a + t * b

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if haunting && hauntedObject!=null:
		HauntObject(delta)
	pass



func _on_player_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return

	body.DealDamage(1)
	

	


func _on_light_checker_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	Disappear()
	pass # Replace with function body.
