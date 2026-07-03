extends Node2D
class_name decoration_slimeball

@onready var animator=$AnimatedSprite2D
@onready var rigidbody:RigidBody2D=$RigidBody2D
var hasHitGround:bool=false


func _ready() -> void:
	
	await animator.animation_finished
	
	animator.speed_scale=0
	animator.animation="falling"
	animator.frame=0
	
func _process(_delta: float) -> void:
	
	if animator.animation=="falling":
		var velocity = self.linear_velocity
	
		#set the animator to use a more speedy sprite if ball is fast
		if velocity.y <30:
			animator.frame=0
		elif velocity.y <120:
			animator.frame=1
		else:
			animator.frame=2
	

func HitGround():
	if hasHitGround:
		return
	hasHitGround=true
	
	animator.speed_scale=1
	animator.play("land")
	
	await get_tree().create_timer(randf_range(1,4)).timeout
	
	var tween = get_tree().create_tween()
	await tween.tween_property($".","modulate:a",0,3).finished
	
	queue_free()	

func _on_rigid_body_2d_body_entered(_body: Node) -> void:
	HitGround()
