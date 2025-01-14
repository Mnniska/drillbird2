extends TileMapLayer
@export var oreRegions: Array[abstract_ore_region]
@export var oreList:Array[abstract_ore]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	
		SpawnOreAtLocation(location,newOre)


func SpawnOreAtLocation(location:Vector2,ore:abstract_ore):
	var scene = load("res://Scenes/Object_Ore.tscn") # Will load when the script is instanced.
	var node = scene.instantiate()
	
	node.transform.origin = map_to_local(location)
	
	add_child(node)
	node.add_to_group("ores")
	node.SetOreType(ore)


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
				SpawnOreAtLocation(locations[n],p)
		pass
	
	pass
