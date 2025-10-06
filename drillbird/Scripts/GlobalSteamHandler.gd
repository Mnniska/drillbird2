extends Node

var AppID="3809940"

#Achievement numbers that may need tweaking, so I am putting them here so I can find them all in one place
@export var stat_ach_days_fastest:int=5

@export var stat_ach_speed_fastest:float=15*60

@export var stat_ach_pacifist:int=10
@export var stat_ach_murderer:int=100

var enemyDeaths:int=0

func SetEnemyDeaths(amount:int):
	enemyDeaths=amount
	print_debug("Enemy count loaded. Count: "+str(enemyDeaths))
	
func IncreaseEnemyDeaths():
	enemyDeaths+=1
	print_debug("Killed enemy! New count: "+str(enemyDeaths))
	if enemyDeaths>=stat_ach_murderer:
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
	pass

func TryUnlockAchievement(name:String):
	if !Steam.isSteamRunning():
		print_debug("Cannot unlock achievement "+name+" since I cannot connect to Steam!")
		return
	
	var status= Steam.getAchievement(name)
	if status["achieved"]:
		print_debug("Already unlocked the achivement: "+name)
		return
	
	Steam.setAchievement(name)
	Steam.storeStats()
	print_debug("Seemingly successfully unlocked achievement: "+name)
	
	
	pass
	
