extends StaticBody2D
@export var length: int
var pixelLength:int=16

@onready var checker:Area2D =$playerChecker
@onready var collider:CollisionShape2D =$PlayerCollider
# Called when the node enters the scene tree for the first time.


func SetCollisionActive(active:bool):
	self.set_collision_layer_value(1,active)


func _on_player_checker_body_entered(body: Node2D) -> void:
	SetCollisionActive(true)
	pass # Replace with function body.


func _on_player_checker_body_exited(body: Node2D) -> void:
	SetCollisionActive(false)
	pass # Replace with function body.
