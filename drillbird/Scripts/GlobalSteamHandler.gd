extends Node

var AppID="3809940"
@export var test:bool

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
		print_debug("Already unlocked the achivement"+name)
		return
	
	Steam.setAchievement(name)
	Steam.storeStats()
	
	
	pass
	
