extends Node

@onready var TileDestroyer=$TileCrack
@onready var EnemySpawner=$EnemySpawner
var save_file_path = "user://save/"
var save_file_name="DrillbirdPlayerSave.tres"

var PlayerData=abstract_savegame.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	verify_save_directory(save_file_path)
	LoadGame()
	LoadDestroyedTiles()
	GlobalVariables.InitialSetup=false
	
	pass # Replace with function body.

func _init() -> void:
	pass
	

func _process(delta: float) -> void:
	pass

func verify_save_directory(path:String):
	DirAccess.make_dir_absolute(path)

func ResetSaveData():
	PlayerData=null
	PlayerData=abstract_savegame.new()
	ResourceSaver.save(PlayerData,save_file_path+save_file_name)


func SaveGame():
	
	PlayerData.upgrade_drill=GlobalVariables.upgradeLevel_drill
	PlayerData.upgrade_health=GlobalVariables.upgradeLevel_health
	PlayerData.upgrade_inventory=GlobalVariables.upgradeLevel_inventory
	PlayerData.upgrade_light=GlobalVariables.upgradeLevel_light
	PlayerData.health=GlobalVariables.playerHealth
	PlayerData.money=GlobalVariables.playerMoney
	PlayerData.totalMoneyGained=GlobalVariables.totalExperienceGained
	
	SaveEnvironment()
	
	ResourceSaver.save(PlayerData,save_file_path+save_file_name)
	print_debug("game saved")

	pass

func SaveEnemyPositions():
	#This is currently NOT USED
	PlayerData.enemies_to_spawn.clear()

	for n in EnemySpawner.UpdateEnemySpawnLocations():
		PlayerData.enemies_to_spawn.append(n)
		
	pass

func LoadEnemyPositions():
	#This is currently NOT USED
	EnemySpawner.LoadEnemySpawns(PlayerData.enemies_to_spawn)

func SaveEnvironment():
	#This will include ores and enemies in the future as well
	PlayerData.destroyed_tiles=TileDestroyer.GetDestroyedTiles()
	pass

func LoadDestroyedTiles():
	TileDestroyer.OnLoadDestroyDugTiles(PlayerData.destroyed_tiles)
	pass

func LoadGame():
	ResourceLoader.CACHE_MODE_IGNORE
	if ResourceLoader.load(save_file_path+save_file_name)!=null:
		PlayerData=ResourceLoader.load(save_file_path+save_file_name)
	SetGlobalVariablesToLoadedGame()
	
	
	print_debug("game loaded")
	
	pass
	
func SetGlobalVariablesToLoadedGame():
	
	GlobalVariables.upgradeLevel_light=PlayerData.upgrade_light
	GlobalVariables.upgradeLevel_health=PlayerData.upgrade_health
	GlobalVariables.upgradeLevel_inventory=PlayerData.upgrade_inventory
	GlobalVariables.upgradeLevel_drill=PlayerData.upgrade_drill

	GlobalVariables.playerHealth=PlayerData.health
	GlobalVariables.playerMoney=PlayerData.money
	GlobalVariables.totalExperienceGained=PlayerData.totalMoneyGained
	
	pass
