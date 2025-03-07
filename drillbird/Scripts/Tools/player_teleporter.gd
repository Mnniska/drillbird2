extends Area2D
@onready var teleportPos:Sprite2D=$TeleportPosition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	teleportPos.hide()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func TeleportFool(player:player_script):
	player.global_position=teleportPos.global_position
	player.TriggerTeleportEffect()
	
	pass

func _on_body_entered(body: Node2D) -> void:
	
	var player=GlobalVariables.PlayerController
	if player!=null:
		if player==body:
			TeleportFool(player)
	
	pass # Replace with function body.
