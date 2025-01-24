extends TileMapLayer
@export var oreRegions: Array[abstract_ore_region]
@export var oreList:Array[abstract_ore]



func TrySpawnOreFromEnvironment(location:Vector2i):
	
	#handle ore spawning
	var cell = self.get_cell_tile_data(location)
	if cell!=null: #is there an ore tile on top of destroyed tile?
		self.set_cell(location,-1,Vector2i(-1,-1),-1)
		
		var oreRegion:int=cell.get_custom_data("ore_region")
		
		var newOre=null
		for n in oreRegions:
			if n.oreRegionID==oreRegion:
				newOre=n.GetOreToSpawn()
		if newOre==null:
			push_error("Crack script was unable to find a good ore!")
	
		var loc = map_to_local(location)
		SpawnOreAtLocation(loc,newOre,Vector2(0,0),false)


func SpawnOreAtLocation(location:Vector2,ore:abstract_ore,velocity:Vector2,cooldown:bool):
	var scene = load("res://Scenes/Objects and Enemies/Object_Ore.tscn") # Will load when the script is instanced.
	var node = scene.instantiate()
	
	node.transform.origin = location
	
	add_child(node)
	#Give ore velocity here - shoooould be possible? 
	
	node.apply_central_impulse(velocity)
	node.add_to_group("ores")
	node.SetOreType(ore,cooldown)


func GetLeftoverOres():
	var _ores = get_tree().get_nodes_in_group("ores")
	
	var oreIDs:Array[int]
	var oreLocations:Array[Vector2i]
	
	for n in _ores:
		var ore:abstract_ore=n.oreType
		oreIDs.append(ore.ID)
		oreLocations.append(local_to_map(n.position))
		
	return [oreIDs,oreLocations]
	
	pass
	
func OnLoadSpawnSavedOres(uniqueIDs:Array[int],locations:Array[Vector2i]):
	
	if uniqueIDs.size()!=locations.size():
		push_error("length of arrays differ in "+str(self))
	
	for n in uniqueIDs.size():
		for p in oreList:
			if p.ID==uniqueIDs[n]:
				SpawnOreAtLocation(map_to_local( locations[n]),p,Vector2(0,0),false)
		pass
	
	pass
