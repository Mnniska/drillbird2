extends Resource
class_name abstract_savegame

#At startup, load the values from this resource into GlobalVariables
#When saving, modify this resource and save it to disk

#Key variables needed to save game
@export var health:int=2
@export var money:int=0
@export var totalMoneyGained:int=0
@export var upgrade_light:int=0
@export var upgrade_drill:int=0
@export var upgrade_health:int=0
@export var upgrade_inventory:int=0

@export var destroyed_tiles:Array[Vector2i]
