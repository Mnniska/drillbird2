extends Base_Enemy

#Todo: Make it spawn ore depending on depth? Or just use it for specific region?
@export var oreToSpawn:abstract_ore

@onready var spawnedCollider= preload("res://Scenes/Objects and Enemies/mole_ore_collider.tscn")
const SPEED = 3
const DISTANCE_TO_FEEL_SAFE = 16*3
const DISTANCE_BEFORE_SPAWNING_NEW_COLLIDER:float=16*6

@onready var detectionArea=$"Detection area"
@onready var sprite=$sprite

var bodyToEscapeFrom:Node2D=null
enum States{IDLE,ESCAPING,DYING}
var state:States=States.IDLE

var collidersForEmptySpaces:Array[Node2D]
var colliderPositions:Array[Vector2i]
var positionOfLastColliderSpawn:Vector2
var tilemap:TileMapLayer
var vibrate:bool=false

func _ready() -> void:
	GlobalVariables.TileDestroyed.connect(PlayerDestroyedTile)


	await GlobalVariables.SetupComplete
	CreateCollidersOnEmptySpaces(GetTilemap())

func GetTilemap()->TileMapLayer:
	if tilemap:
		return tilemap
	else:
		tilemap=GlobalVariables.MainSceneReferenceConnector.ref_environmentTilemap
		return tilemap

func Setup(info:abstract_enemy): #MUST HAVE
	#This happens AFTER the enemy has spawned, so i just need to make sure this check has happened b4 enemy spawns
	enemyInfo=enemyInfo.duplicate()
	enemyInfo.spawnLocation=info.spawnLocation
	enemyInfo.currentSpawnLocation=info.currentSpawnLocation
	enemyInfo.dead=info.dead
		
	spawnPositionLocal=position #MUST HAVE
	GlobalVariables.signal_IsPlayerInMenuChanged.connect(SetGamePaused)
	

	
	setupComplete=true
	
	


func _physics_process(_delta: float) -> void:
	
	var _anim:String=sprite.animation
	match state:
		States.IDLE:
			velocity=Vector2(0,0)
			vibrate=false
			_anim="idle"
			pass
		States.ESCAPING:
			vibrate=true
			_anim="walk"
			if bodyToEscapeFrom==null:
				print_debug("no body to escape from")
				state=States.IDLE
				return
				
			var movementV=GetMovementVector(bodyToEscapeFrom.global_position)
			velocity+=movementV*SPEED
			
			var p = randf_range(-10,10)
			var y =randf_range(-10,10)
			velocity+=Vector2(p,y)
			
			if global_position.distance_to(bodyToEscapeFrom.global_position)>=DISTANCE_TO_FEEL_SAFE:
				state=States.IDLE
			
			if global_position.distance_to(positionOfLastColliderSpawn)>DISTANCE_BEFORE_SPAWNING_NEW_COLLIDER:
				CreateCollidersOnEmptySpaces(GetTilemap())
			
			

	if vibrate:
		var d=0.5
		$sprite.position=Vector2(randf_range(-d,d),randf_range(-d,d))
	move_and_slide()
	HandleVisuals(_anim)

func HandleVisuals(_animToPlay:String):
	if sprite.animation!=_animToPlay:
		sprite.play(_animToPlay)
		

func PlayerDestroyedTile(tilemapCoord:Vector2i,_tilemap:TileMapLayer):
	
	var distance=_tilemap.to_global(_tilemap.map_to_local(tilemapCoord)).distance_to(global_position)
	if distance<DISTANCE_BEFORE_SPAWNING_NEW_COLLIDER:
		pass
		
		if _tilemap.local_to_map(_tilemap.to_local(global_position)) == tilemapCoord:
			#the block lil fucker is standing on has been destroyed
			RestingBlockDestroyed()
		
		SpawnIndvidualCollider(tilemapCoord)
	
	pass

func RestingBlockDestroyed():
	
	#TODO:
	#spawn a mole maybe??
	#Spawn an appropiate ore
	#destroy this bad boi
	
	var spawner:ore_manager = GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	spawner.SpawnOreAtLocation(global_position,oreToSpawn,Vector2(0,-100),true)
	
	for n in collidersForEmptySpaces:
		n.queue_free()
	queue_free()
	pass

func SpawnIndvidualCollider(tilemapPos):
	
	if !colliderPositions.has(tilemapPos):
		var coll:Node2D = spawnedCollider.instantiate()
		get_parent().add_child(coll)
		coll.global_position=GetTilemap().to_global(GetTilemap().map_to_local(tilemapPos))
		collidersForEmptySpaces.append(coll)
		colliderPositions.append(tilemapPos)
	

func CreateCollidersOnEmptySpaces(_tilemap:TileMapLayer):
	
	var localPositionInTilemap=_tilemap.to_local(global_position)
	var positionInTilemap=_tilemap.local_to_map(localPositionInTilemap)
	
	var widthToCheck:int=12
	
	for x in widthToCheck:
		for y in widthToCheck:
			var posToCheck=positionInTilemap+Vector2i(x - widthToCheck/2,y-widthToCheck/2)
			
			if _tilemap.get_cell_tile_data(posToCheck) == null:
				SpawnIndvidualCollider(posToCheck)
				
			pass
	
	positionOfLastColliderSpawn=global_position
	


	
	
	pass

func GetMovementVector(_targetPosGlobal:Vector2):
	var directionVector=global_position - _targetPosGlobal
	var normalizedDirectionVector=directionVector.normalized()
	return normalizedDirectionVector

func _on_detection_area_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if state==States.IDLE:
		state=States.ESCAPING
		bodyToEscapeFrom=body
	
	pass # Replace with function body.
