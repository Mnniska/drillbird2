extends Area2D
class_name OreArea

@export var terrainIdentifier:int=0
@onready var collider=$CollisionShape2D
var debugspawnable=preload("res://Scenes/Tools/debug_spawnable.tscn")


func GetIsOverlapping():
	
	for n in get_overlapping_areas(): #Assumes layer 6 is dedicated to this purpose. Ugly and bad, but we gotta MOVE ON :D 
		return true
	return false

func GetBoundingBoxBegin():
	var size:Vector2 = collider.shape.size
	var pos= collider.global_position+Vector2(-size.x/2,-size.y/2)
	SpawnAtGlobalPos(pos,"begin")
	return pos

func GetBoundingBoxEnd():
	var size:Vector2 = collider.shape.size
	var pos= collider.global_position+Vector2(size.x/2,size.y/2)
	SpawnAtGlobalPos(pos,"end")
	return pos
	
func SpawnAtGlobalPos(pos:Vector2,_text:String):
	var node=debugspawnable.instantiate()
	var parent = GlobalVariables.MainSceneReferenceConnector.mainScene
	parent.add_child(node)
	node.global_position=pos
	node.get_child(0).text=_text
	
