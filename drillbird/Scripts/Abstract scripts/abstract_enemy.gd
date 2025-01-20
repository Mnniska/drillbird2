extends Resource
class_name abstract_enemy

enum enemyTypes{MOLE,SPIKE}
@export var type:enemyTypes
@export var spawnLocation:Vector2i
@export var dead:bool=false
@export var damage:int=1
