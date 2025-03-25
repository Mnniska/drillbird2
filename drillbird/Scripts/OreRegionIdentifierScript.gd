extends Node2D
var oreAreas:Array[OreArea]
@onready var raycast:RayCast2D=$RayCast2D
@onready var oreTilemap:TileMapLayer=$".."

#This script:
#1 - Accepts a vvector2i location in tilemap coordinates and returns the relevant
#ORE REGION IDENTIFIER by checking the location against the various Area2Ds under this parent. 
# Each Area2D has its own script - OreArea which is responsible for checking whether
#the given location is within the area

func _ready() -> void:
	for n in get_children():
		if n.name!="CheckerArea" && n.name!="RayCast2D":
			oreAreas.append(n)

func GetAmountOfOreTiles():
	var amount:int=0
	for oreLoc in oreTilemap.get_used_cells():
		amount+=1
	
	return amount

func GetValueOfOresForRegion(regionID:int):
	if regionID<0:
		push_error("Recieved invalid region ID: "+str(regionID) )
		regionID=0
	if regionID>4:
		push_error("Recieved invalid region ID: "+str(regionID) )
		regionID=4
	
	var areasToCheck:Array[OreArea]
	
	for n in oreAreas:
		if n.terrainIdentifier==regionID:
			areasToCheck.append(n)
	
	var amountOfOres:int=0
	var estimatedValue:int=0
	for _oreArea in areasToCheck:
		var startingPos=_oreArea.GetBoundingBoxBegin()
		var endPos=_oreArea.GetBoundingBoxEnd()
			
		for orePos in oreTilemap.get_used_cells():
			var globalOrePos=to_global(oreTilemap.map_to_local(orePos))
			
			if globalOrePos.x>startingPos.x and globalOrePos.x < endPos.x:
				if globalOrePos.y>startingPos.y and globalOrePos.y < endPos.y:
					var cell = oreTilemap.get_cell_tile_data(orePos)
					var oreRegion:int=cell.get_custom_data("ore_region")
			
					var newOre:abstract_ore=null
					for n in oreTilemap.oreRegions:
						if n.oreRegionID==oreRegion:
							newOre=n.GetOreToSpawn()
					if newOre==null:
						push_error("Crack script was unable to find a good ore!")
					
					amountOfOres+=1
					estimatedValue+=newOre.value
				
	print_debug("Amount of ores in area: "+str(amountOfOres))
	print_debug("Estimated value of ores: "+str(estimatedValue))
	
	

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
