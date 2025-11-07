extends Node

var AppID="3809940"

#Achievement numbers that may need tweaking, so I am putting them here so I can find them all in one place
@export var stat_ach_days_fastest:int=7

@export var stat_ach_speed_fastest:float=20*60

@export var stat_ach_pacifist:int=0
@export var stat_ach_murderer:int=50
@export var stat_ach_flower_height_in_tiles:float=90

var count_enemyDeaths:int=0

func SetEnemyDeaths(amount:int):
	count_enemyDeaths=amount
	print_debug("Enemy count loaded. Count: "+str(count_enemyDeaths))
	
func IncreaseEnemyDeaths():
	count_enemyDeaths+=1
	print_debug("Killed enemy! New count: "+str(count_enemyDeaths))
	if count_enemyDeaths>=stat_ach_murderer:
		TryUnlockAchievement("ach_murderer")

func _init():
	OS.set_environment("SteamAppID",AppID)
	OS.set_environment("SteamGameID",AppID)
	
func _ready() -> void:
	Steam.steamInit()
	var isRunning= Steam.isSteamRunning()
	
	if !isRunning:
		print("ERROR: Steam isn't running!")
	else:
		print("Successfully detected Steam! Your user name is "+Steam.getFriendPersonaName(Steam.getSteamID()))
		Steam.requestUserStats(Steam.getSteamID())
	pass

func TryUnlockAchievement(name:String):
	if !Steam.isSteamRunning():
		print_debug("Cannot unlock achievement "+name+" since I cannot connect to Steam!")
		return
	
	var status= Steam.getAchievement(name)
	if status.size()<=0:
		print_debug("Steam didn't find the given achievement, it seems: "+name)
		return
		
	if status["achieved"]:
		print_debug("Asked Steam to unlock an achievement which was already unlocked: "+name)
		return
	
	
	Steam.setAchievement(name)
	Steam.storeStats()
	print_debug("Have asked Steam to unlock the achievement: "+name)
	
	
	pass
	
