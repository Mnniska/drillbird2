extends Node2D
@export var collType:abstract_collidable

var hauntedObject:Node2D
var playerPos:Vector2
var SPEED:float=2.8
var  haunting:bool=false
var lastpos:Vector2
@onready var collider=$PlayerChecker

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
func GetCollType():
	return collType

func HauntObject(delta:float):
	
	var speedmod=10
	var s=SPEED*speedmod*delta
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
	for n in collider.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(1)
		pass
	
	pass

func Disappear():
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
	
	pass # Replace with function body.
