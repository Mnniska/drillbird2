extends enemy_spikes
class_name tombstone

var spawnedGhast:ghast=null
@onready var loadedGhast=preload("res://Scenes/Objects and Enemies/enemy_ghast.tscn")
@onready var ghostPath:Line2D=$"Ghost path"
func GetCollType():
	return collType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemyInfo=enemyInfo.duplicate()

	await get_tree().create_timer(0.1).timeout #TODO: Figure out a way to do this that isn't timing dependent - need to wait for tilemaplayers to generate	
	
	SpikesSpawnSetup()
	spawnPositionLocal=position
	
	SpawnGhast()
		
	pass # Replace with function body.

func SpikesSpawnSetup():
	raycast.force_raycast_update()
	if raycast.is_colliding():
		var col =raycast.get_collider()
		if col is TileMapLayer:

			var spikePos=col.local_to_map( col.to_local( raycast.global_position) )
			var affectedTile= col.get_cell_tile_data(spikePos)
			var terrain = affectedTile.terrain
			#Todo: Make terrain sprite match terrain spawned on
			
			
#			$Sprite2D.texture=spriteVariations[min(spriteVariations.size()-1,terrain) ] 
			
			return true
		else:
			TurnEnemyOff()
	else:
		TurnEnemyOff()

func SpawnGhast():
	var ghastInstance:ghast = loadedGhast.instantiate()
	add_child(ghastInstance)
	
	await get_tree().create_timer(0.1).timeout
	
	ghastInstance.SetupGhast(ghostPath,self)
	ghastInstance.ReturnToLine()
	spawnedGhast=ghastInstance

func TurnEnemyOff():
	$Sprite2D.hide()
	$Sprite_front.hide()
	#should prolly do a proper destroy anim as well but w/e for now

	$".".set_deferred("disabled",true)
	$SpikeAffectedCollider.set_deferred("disabled",true)
	$Collider.set_deferred("disabled",true)
	$Collider.set_deferred("monitoring",false)
	enemyInfo.dead=true	
	
	if spawnedGhast!=null:
		spawnedGhast.Despawn()
	
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

func DealDamage(amount:int):
	return
	

func GetLocalSpawnPosition():
	return spawnPositionLocal

func _on_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	
	body.DealDamage(enemyInfo.damage)
	
	pass # Replace with function body.


func _on_observer_block_destroyed() -> void:
	TurnEnemyOff()
	
	pass # Replace with function body.
