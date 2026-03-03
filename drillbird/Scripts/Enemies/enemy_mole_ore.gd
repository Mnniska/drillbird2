extends CharacterBody2D

@onready var spawnedCollider= preload("res://Scenes/Objects and Enemies/mole_ore_collider.tscn")
const SPEED = 5
const DISTANCE_TO_FEEL_SAFE = 16*3
const DISTANCE_BEFORE_SPAWNING_NEW_COLLIDER:float=16*6

@onready var detectionArea=$"Detection area"

var bodyToEscapeFrom:Node2D=null
enum States{IDLE,ESCAPING,DYING}
var state:States=States.IDLE

var colliders:Array[Node2D]
var colliderPositions:Array[Vector2i]
var positionOfLastColliderSpawn:Vector2
var tilemap:TileMapLayer

func _ready() -> void:
	
	await GlobalVariables.SetupComplete
	tilemap=GlobalVariables.MainSceneReferenceConnector.ref_environmentTilemap
	CreateCollidersOnEmptySpaces(tilemap)
	GlobalVariables.TileDestroyed.connect(PlayerDestroyedTile)

func _physics_process(delta: float) -> void:
	
	match state:
		States.IDLE:
			velocity=Vector2(0,0)
			pass
		States.ESCAPING:
			
			if bodyToEscapeFrom==null:
				print_debug("no body to escape from")
				state=States.IDLE
				return
				
			var movementV=GetMovementVector(bodyToEscapeFrom.global_position)
			velocity+=movementV*SPEED
			
			if global_position.distance_to(bodyToEscapeFrom.global_position)>=DISTANCE_TO_FEEL_SAFE:
				state=States.IDLE
			
			if global_position.distance_to(positionOfLastColliderSpawn)>DISTANCE_BEFORE_SPAWNING_NEW_COLLIDER:
				CreateCollidersOnEmptySpaces(GlobalVariables.MainSceneReferenceConnector.ref_environmentTilemap)
			
			pass


	move_and_slide()


func PlayerDestroyedTile(tilemapCoord:Vector2i,tilemap:TileMapLayer):
	
	var distance=tilemap.to_global(tilemap.map_to_local(tilemapCoord)).distance_to(global_position)
	if distance<DISTANCE_BEFORE_SPAWNING_NEW_COLLIDER:
		pass
		SpawnIndvidualCollider(tilemapCoord)
	
	pass

func SpawnIndvidualCollider(tilemapPos):
	
	if !colliderPositions.has(tilemapPos):
		var coll:Node2D = spawnedCollider.instantiate()
		get_parent().add_child(coll)
		coll.global_position=tilemap.to_global(tilemap.map_to_local(tilemapPos))
		colliders.append(coll)
		colliderPositions.append(tilemapPos)
	

func CreateCollidersOnEmptySpaces(tilemap:TileMapLayer):
	
	var localPositionInTilemap=tilemap.to_local(global_position)
	var positionInTilemap=tilemap.local_to_map(localPositionInTilemap)
	
	var widthToCheck:int=12
	
	for x in widthToCheck:
		for y in widthToCheck:
			var posToCheck=positionInTilemap+Vector2i(x - widthToCheck/2,y-widthToCheck/2)
			
			if tilemap.get_cell_tile_data(posToCheck) == null:
				SpawnIndvidualCollider(posToCheck)
				
			pass
	
	positionOfLastColliderSpawn=global_position
	


	
	
	pass

func GetMovementVector(_targetPosGlobal:Vector2):
	var directionVector=global_position - _targetPosGlobal
	var normalizedDirectionVector=directionVector.normalized()
	return normalizedDirectionVector

func _on_detection_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if state==States.IDLE:
		state=States.ESCAPING
		bodyToEscapeFrom=body
	
	pass # Replace with function body.
