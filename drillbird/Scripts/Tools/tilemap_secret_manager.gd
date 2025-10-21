extends TileMapLayer
class_name tilemap_secrets_manager

@onready var tilemap:TileMapLayer=$"."
var removeQueue:Array[Vector2i]
var checkQueue:Array[Vector2i]
var amount:int=0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

#the target tile is added to the action queue 
#The action queue script removes target tile. Once action queue is empty.. 
#the game checks all tiles around the action tile - adds them to action queue
#Game loops through action queue and destroys tiles, adds them to invesigfation queue 
#game loops thru invest queue, and adds any tiles there to action queue. and so on..


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func TryUnveilTargetPosition(pos:Vector2i):
	
	var targetTile= tilemap.get_cell_tile_data(pos)
	
	if targetTile!=null:
		removeQueue.append(pos)
	else:
		print_debug("Attempted to remove a tile that does not seem to exist!")
	
	while removeQueue.size()>0:

#		InvestigateTile(investigationQueue[0])
		RemoveTargetedTiles()
		await get_tree().create_timer(0.08).timeout
		removeQueue=checkQueue.duplicate()
		print_debug("Check queue size: "+str(checkQueue.size()))
		checkQueue.clear()
		pass


func RemoveTargetedTiles():
	
	for pos in removeQueue:
		tilemap.set_cell (pos,-1,Vector2i(-1,-1),-1)
		InvestigateNeighbors(pos)
	amount+=1
	print_debug("Remove queue size: "+str(removeQueue.size()))
	print_debug("amount of times checked:" +str(amount))
	removeQueue.clear()

func InvestigateNeighbors(pos):
	
	var investPos:Vector2i
	
	investPos=pos+Vector2i(1,0)
	if tilemap.get_cell_tile_data(investPos):
		checkQueue.append(investPos)
		
	investPos=pos+Vector2i(-1,0)
	if tilemap.get_cell_tile_data(investPos):
		checkQueue.append(investPos)		
	
	investPos=pos+Vector2i(0,-1)
	if tilemap.get_cell_tile_data(investPos):
		checkQueue.append(investPos)
	
	investPos=pos+Vector2i(0,1)
	if tilemap.get_cell_tile_data(investPos):
		checkQueue.append(investPos)
	pass
