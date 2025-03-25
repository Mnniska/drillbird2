extends Resource
class_name abstract_savegame

#At startup, load the values from this resource into GlobalVariables
#When saving, modify this resource and save it to disk

#Key variables needed to save game
@export var currentDay:int=1
@export var eggState:int=0 

@export var playerSpawnPosition:Vector2=Vector2(0,0)
@export var health:int=2
@export var money:int=0
@export var totalEGGsperienceGained:int=0
@export var upgrade_light:int=0
@export var upgrade_drill:int=0
@export var upgrade_health:int=0
@export var upgrade_inventory:int=0

@export var destroyed_tiles:Array[Vector2i]
@export var enemies_to_spawn:Array[abstract_enemy]

@export var enemyCurrentSpawnPositions:Array[Vector2i]
@export var enemySpawnPositions:Array[Vector2i] #This should be called origin spawn positons - but keeping it as is for savefile compatibility reasons
@export var enemyTypes:Array[int]
@export var enemyDead:Array[bool]
@export var flowerSpawnPositions:Array[Vector2i]

@export var oreIDs:Array[int]
@export var oreLocations:Array[Vector2i]
@export var hasSeenIntroCutscene:bool=false

@export var timeLastSaved:float=0
@export var totalOres:int=0 #Should be set during first startup
@export var oresFound:int=0
