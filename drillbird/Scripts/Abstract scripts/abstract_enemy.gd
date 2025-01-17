extends Resource
class_name abstract_enemy

enum enemyTypes{MOLE,RUNNER}
@export var type:enemyTypes
@export var spawnLocation:Vector2i
@export var dead:bool=false
