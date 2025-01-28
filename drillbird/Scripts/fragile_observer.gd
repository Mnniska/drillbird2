extends Node2D
class_name fragile_observer
@onready var observer=preload("res://Scenes/observer.tscn")
var tileDestroyer:crack_script
var locationInSpritesheet:Vector2i
var isDying:bool=false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func GenerateObservers(location:Vector2i,_tilemap:TileMapLayer,tileDestroy:crack_script):
	tileDestroyer=tileDestroy
	locationInSpritesheet=location
	#Creates an observer left,right,up,down if there's a fellow fragile block next to it. 
	#The observer will notify this script if the block is destroyed - if so this block is also destroyed
	
	var directions:Array[Vector2i]=[Vector2i(0,1),Vector2i(0,-1),Vector2i(1,0),Vector2i(-1,0)]
	
	for vector in directions:
		var cell= _tilemap.get_cell_tile_data(location+vector)
		if cell:
			if cell.terrain==4:
				
				var obs:observerScript = observer.instantiate()
				
				obs.BlockDestroyed.connect(DestroySelf)
				obs.BlockDestroyed.connect(obs.queue_free)
				
	#			var globalloc:Vector2=to_global(tilemap.map_to_local(location))
				obs.transform.origin=Vector2(float(vector.x),float(vector.y))*16
				add_child(obs)
			
	
func DestroySelf():
	#Here I need some sorta BLOCK MANAGER to kindly destroy this tile for them. 
	#If I simply contact the tilemap - then the neccesary OBSERVER triggers won't be abided by
	#So..I can create a BlockDestroyerManager which anything can call upon which handles this
	#or I can keep using the crack script, destroying everything from there
	#I think crack script is OK for now since we're almost content complete, but should be a bit wary
	if !isDying:
		isDying=true
		await get_tree().create_timer(0.1).timeout
		tileDestroyer.DestroyTile(locationInSpritesheet,true)
		queue_free()
	
	pass
