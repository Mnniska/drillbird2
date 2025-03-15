extends Resource
class_name abstract_enemy

enum enemyTypes{MOLE,SPIKE,FOLLOWER,FALLBLOCK,UPSIDEDOWN}
@export var type:enemyTypes
var spawnLocation:Vector2i
var currentSpawnLocation:Vector2i
var dead:bool=false
@export var damage:int=1
