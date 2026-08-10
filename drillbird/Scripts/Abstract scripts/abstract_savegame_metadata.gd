extends Resource
class_name abstract_savegame_metadata

#This resource is used to track metadata across the game 
#Just like the regular savedata, the data from this is loaded into GlobalVariables during startup, accessible for any scripts interested in it
#right now it is only needed for..
#1. Demon needs to reject the player if they've never hatched the egg b4 
#2. The credit final stats scene needs to show how many endings the player has unlocked


@export var test:String="not changed"
@export var normalEndingFound:bool=false
@export var cursedModeBadEndingFound:bool=false
@export var cursedModeTrueEndingFound:bool=false
