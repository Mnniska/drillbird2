extends Node2D
var oreAreas:Array[OreArea]
@onready var raycast:RayCast2D=$RayCast2D

#This script:
#1 - Accepts a vvector2i location in tilemap coordinates and returns the relevant
#ORE REGION IDENTIFIER by checking the location against the various Area2Ds under this parent. 
# Each Area2D has its own script - OreArea which is responsible for checking whether
#the given location is within the area

func _ready() -> void:
	for n in get_children():
		if n.name!="CheckerArea":
			oreAreas.append(n)



func GetRegionIdentifierFromLocation(tilemapPos:Vector2i,tilemap:TileMapLayer):
	
	var num:int=0

	var globalLoc=to_global(tilemap.map_to_local(tilemapPos))
	
	
	raycast.global_position=globalLoc
	raycast.force_raycast_update()
	if raycast.is_colliding(): 
		var coll=raycast.get_collider()
		num=max(num,coll.terrainIdentifier)
		pass
	

	
	return num


func _on_checker_area_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	print_debug("found this fucken area, it has terrain identifier "+str(area.terrainIdentifier))
	
	pass # Replace with function body.
