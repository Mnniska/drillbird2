extends Resource
class_name abstract_chunk

enum directions{up,right,down,left}
@export var wallDirections:Array[directions]
@export var depth:int

var chunkDimensions:Vector2i 

#Variables to save tiles.
#I would love to just have a tile resource - but you can't save resources within resources hehe
@export var positions:Array[Vector2i]
@export var terrains:Array[int]
@export var enemyTypes:Array[int]
@export var objectTypes:Array[int]

#Todo: need to save this as four seperate values since resources within resources aint it
