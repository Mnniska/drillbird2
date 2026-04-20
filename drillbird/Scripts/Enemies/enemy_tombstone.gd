extends enemy_spikes
class_name tombstone

var spawnedGhast:ghast=null
@onready var loadedGhast=preload("res://Scenes/Objects and Enemies/enemy_ghast.tscn")
@onready var ghostPath:Line2D=$"Ghost path"

var oreSpawner:ore_manager
@export var oreToSpawn:abstract_ore
@onready var tombstoneSpikes=$Sprite_spikes

@export var terrainSprites:Array[CompressedTexture2D]


func GetCollType():
	return collType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemyInfo=enemyInfo.duplicate()

	await get_tree().create_timer(0.1).timeout #TODO: Figure out a way to do this that isn't timing dependent - need to wait for tilemaplayers to generate	
	
	
	if !enemyInfo.dead:
		if TombstoneSpawnSetup():		
			SpawnGhast()

	spawnPositionLocal=position		


func TombstoneSpawnSetup():
	#returns true if spike successfully spawns - tombstones spawning in thin air won't spawn
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
			return false
	else:
		TurnEnemyOff()
		return false

func SpawnGhast():
	var ghastInstance:ghast = loadedGhast.instantiate()
	add_child(ghastInstance)
	
	await get_tree().create_timer(0.1).timeout
	
	ghastInstance.SetupGhast(ghostPath,self)
	ghastInstance.ReturnToLine()
	spawnedGhast=ghastInstance

func TurnEnemyOff(spawnOre:bool=false):
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
	
	if spawnOre:
		if oreSpawner:
			oreSpawner.SpawnOreAtLocation(self.global_position,oreToSpawn,Vector2(0,-100),false,false)
	
	if spawnedGhast!=null:
		await get_tree().create_timer(5).timeout
		
	queue_free()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func CheckOverlappingCollisions(): #MUST HAVE
	for n in $Collider.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(enemyInfo.damage)
	pass

func Setup(info:abstract_enemy,_hasSpikes:bool=false):
	enemyInfo.spawnLocation=info.spawnLocation
	enemyInfo.dead=info.dead
	enemyInfo.type=info.type
	enemyInfo.spawnedFromCorpse=info.spawnedFromCorpse
	spawnPositionLocal=position
	
	if GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap==null:
		print_debug("Could not get ore tilemap for tombstone!")
	else:
		oreSpawner=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap

func DealDamage(amount:int):
	#Tombstone cannot be hurt by normal means
	return

func CrushByFallblock():
	TurnEnemyOff(false)	
	

func GetLocalSpawnPosition():
	return spawnPositionLocal

func _on_collider_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return
	#tonbstone does not deal damage, keeping function in case I change my mind ;) 


func _on_observer_block_destroyed() -> void:
	TurnEnemyOff(true)
	
	pass # Replace with function body.
