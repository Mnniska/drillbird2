extends Node2D
@export var enemyInfo:abstract_enemy=abstract_enemy.new()
@export var collType:abstract_collidable #MUST HAVE
@onready var raycast=$RayCast2D
var spawnPositionLocal:Vector2
var tilemap:TileMapLayer

func GetCollType():
	return collType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	await get_tree().create_timer(0.1).timeout #TODO: Figure out a way to do this that isn't timing dependent - need to wait for tilemaplayers to generate
	
	raycast.force_raycast_update()

	var coll = raycast.get_collider()
		
	if coll:
		tilemap=coll
		tilemap.changed.connect(CheckIfTileExists) #TODO: Instead of this shit - could have the crack one check if there's any surrounding colliders and ask them to update when brekaing a block..but that wont allow enemies to break blocks
	#tilemap
	
	CheckIfTileExists()
	spawnPositionLocal=position
	pass
	
	pass # Replace with function body.

func CheckIfTileExists():
	raycast.force_raycast_update()
	if raycast.is_colliding():
		print_debug("Successfully detected floor")

		return true
	else:
		TurnEnemyOff()

func TurnEnemyOff():
	hide()
	$".".set_deferred("disabled",true)
	$Collider.set_deferred("disabled",true)
	$Collider.set_deferred("monitoring",false)
	enemyInfo.dead=true	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func CheckOverlappingCollisions(): #MUST HAVE
	for n in $Collider.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(enemyInfo.damage)
	pass

func Setup(info:abstract_enemy):
	enemyInfo.spawnLocation=info.spawnLocation
	enemyInfo.dead=info.dead
	enemyInfo.type=info.type
	spawnPositionLocal=position


func GetLocalSpawnPosition():
	return spawnPositionLocal

func _on_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)
	
	pass # Replace with function body.
