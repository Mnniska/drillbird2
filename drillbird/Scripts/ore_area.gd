extends Area2D
class_name OreArea

@export var terrainIdentifier:int=0
@onready var collider=$CollisionShape2D


func GetIsOverlapping():
	
	for n in get_overlapping_areas(): #Assumes layer 6 is dedicated to this purpose. Ugly and bad, but we gotta MOVE ON :D 
		return true
	return false
