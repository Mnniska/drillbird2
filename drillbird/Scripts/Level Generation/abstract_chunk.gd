extends Resource
class_name abstract_chunk

enum directions{up,right,down,left}
@export var wallDirections:Array[directions]
@export var depth:int

var chunkDimensions:Vector2i 
var chunk:Array[tileinfo]
