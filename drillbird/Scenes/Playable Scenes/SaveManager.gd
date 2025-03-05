extends Node

@onready var TileDestroyer=$TileCrack
@onready var EnemySpawner=$ObjectSpawner
@onready var Savetext=$"Camera2D/Day counter"
@onready var OreSpawner=$TilemapOres
@onready var player = $Player
@onready var OriginalSpawnPos=$PlayerSpawnLocations/OriginalSpawnPos
@onready var introCutscene=$IntroCutscene

signal signal_GameAboutToBeSaved

var save_file_path = "user://save/"
var save_file_name="DrillbirdPlayerSave.tres"

var PlayerData=abstract_savegame.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	verify_save_directory(save_file_path)
	LoadGame()
	LoadDestroyedTiles()
	GlobalVariables.InitialSetup=false
	
	SetupMiscGameLogicBeforeStart()
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
	signal_GameAboutToBeSaved.emit()
	await get_tree().create_timer(0.02).timeout
	PlayerData.upgrade_drill=GlobalVariables.upgradeLevel_drill
	PlayerData.upgrade_health=GlobalVariables.upgradeLevel_health
	PlayerData.upgrade_inventory=GlobalVariables.upgradeLevel_inventory
	PlayerData.upgrade_light=GlobalVariables.upgradeLevel_light
	PlayerData.health=GlobalVariables.playerHealth
	PlayerData.money=GlobalVariables.playerMoney
	PlayerData.totalEGGsperienceGained=GlobalVariables.totalEGGsperienceGained
	PlayerData.playerSpawnPosition = GlobalVariables.playerSpawnPos
	PlayerData.hasSeenIntroCutscene=GlobalVariables.hasSeenIntroCutscene
	
	PlayerData.currentDay=GlobalVariables.currentDay
	PlayerData.eggState=GlobalVariables.eggState
	SaveEnvironment()
	SaveEnemies()
	SaveFlowers()
	SaveLeftoverOres()
	
	ResourceSaver.save(PlayerData,save_file_path+save_file_name)
	print_debug("game saved")
	
	Savetext.Activate(GlobalVariables.currentDay)
	
	pass

func SaveLeftoverOres():
	var a = OreSpawner.GetLeftoverOres()
	var ids=a[0]
	var locs=a[1]
	
	PlayerData.oreIDs=ids
	PlayerData.oreLocations=locs

func LoadLeftoverOres():
	
	OreSpawner.OnLoadSpawnSavedOres(PlayerData.oreIDs,PlayerData.oreLocations)
	
	pass
func SaveEnemies():

	PlayerData.enemySpawnPositions.clear()
	PlayerData.enemyTypes.clear()
	PlayerData.enemyDead.clear()

	for n:abstract_enemy in EnemySpawner.GetEnemyUpdate():
		
		PlayerData.enemySpawnPositions.append(n.spawnLocation)
		PlayerData.enemyTypes.append(n.type)
		PlayerData.enemyDead.append(n.dead)
	
		print_debug("spawnpos "+ str(n.spawnLocation))
		
	pass

func SaveFlowers():
	PlayerData.flowerSpawnPositions.clear()
	PlayerData.flowerSpawnPositions=EnemySpawner.GetFlowerUpdate()
	
	pass

func LoadEnemyPositions():
	#This is currently NOT USED
	EnemySpawner.LoadEnemySpawns(PlayerData.enemySpawnPositions,PlayerData.enemyTypes,PlayerData.enemyDead)

func LoadFlowers():
	EnemySpawner.LoadFlowers(PlayerData.flowerSpawnPositions)
	
	pass

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
	LoadEnemyPositions()
	LoadFlowers()
	LoadLeftoverOres()
	GlobalVariables.playerSpawnPos=PlayerData.playerSpawnPosition
	
	print_debug("game loaded")
	
	pass
	
func SetGlobalVariablesToLoadedGame():
	
	GlobalVariables.upgradeLevel_light=PlayerData.upgrade_light
	GlobalVariables.upgradeLevel_health=PlayerData.upgrade_health
	GlobalVariables.upgradeLevel_inventory=PlayerData.upgrade_inventory
	GlobalVariables.upgradeLevel_drill=PlayerData.upgrade_drill

	GlobalVariables.playerHealth=PlayerData.health
	GlobalVariables.playerMoney=PlayerData.money
	GlobalVariables.totalEGGsperienceGained=PlayerData.totalEGGsperienceGained
	GlobalVariables.currentDay=PlayerData.currentDay
	GlobalVariables.eggState=PlayerData.eggState
	
	GlobalVariables.hasSeenIntroCutscene=PlayerData.hasSeenIntroCutscene
	
		
	
func SetupMiscGameLogicBeforeStart():
	var camera:game_camera= GlobalVariables.MainSceneReferenceConnector.ref_camera

	if !PlayerData.hasSeenIntroCutscene:
		PlayerData.playerSpawnPosition=OriginalSpawnPos.global_position
		player.global_position=PlayerData.playerSpawnPosition
		camera.StartNewLerp(introCutscene.cameraPositions[0].global_position,0)
	else:
		player.global_position=PlayerData.playerSpawnPosition

		
	pass
