extends Resource
class_name abstract_enemy

enum enemyTypes{BUG,SPIKE,FOLLOWER,FALLBLOCK,UPSIDEDOWN,SWORDFISH,TOMBSTONE,GHAST,RUNNINGGEM, MOLE ,CORPSE}
@export var type:enemyTypes
var spawnLocation:Vector2i
var currentSpawnLocation:Vector2i
var dead:bool=false
var spawnedFromCorpse:bool=false
@export var damage:int=1
