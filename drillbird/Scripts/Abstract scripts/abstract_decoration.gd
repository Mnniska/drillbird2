extends Resource
class_name abstract_decoration

@export var deco_position:Vector2i
@export var dependencyVector:Vector2i
@export var active:bool=true

func GetDependencyPosition():
	return deco_position+dependencyVector
	
