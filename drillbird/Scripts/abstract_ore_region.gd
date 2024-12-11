extends Resource
class_name abstract_ore_region

@export var potentialOres:Array[abstract_ore]
@export var spawnChances:Array[float]
@export var oreRegionID:int

func _ready():
	var x=0
	for n in spawnChances:
		x+=n
	if x!=1:
		push_error("Invalid chance distribution in abstract ore region, chances should combine to be exactly 1")
		

#This function is dangerous! I like it!
func GetOreToSpawn(): 
	var seed=randf()
	var cumulativeWeight=0.0
	for i in range(spawnChances.size()):
		cumulativeWeight+=spawnChances[i]
		if seed<=cumulativeWeight:
			return potentialOres[i]
	
	
	#code stolen from the internets - supposedly returns an ore based on the random percentages ;) 
	return potentialOres[randi() % spawnChances.size()]
	
	potentialOres.pick_random()
	
	pass
