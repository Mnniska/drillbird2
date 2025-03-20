extends Node2D
class_name ghost_manager

var ghostRef
var ghostInScene:ghost
var ghostSpawned:bool=false
@onready var player= $"../Player"
@onready var HeartRightfulPlace=$HeartsRightfulPlaceArea
#ghost spawning variables
@export var minTimeBeforeGhostSpawns:float=0.2
@export var maxTimeBeforeGhostSpawns:float=2
var TimeBeforeGhostComes:float=minTimeBeforeGhostSpawns
var ghostTimeCounter:float=0
var ghostIsComing:bool=false
var textBubblePath=preload("res://Scenes/UI/text_bubble.tscn")
var orespawner:ore_manager
@export var heartOreReference:abstract_ore
@onready var ghostAcceptanceArea=$GhostAcceptanceArea
var heartInEgg:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"..".signal_GameAboutToBeSaved.connect(GameAboutToBeSaved)
	GlobalVariables.playerLightStatusChange.connect(playerLightStatusChanged)
	ghostRef=preload("res://Scenes/Objects and Enemies/ghost.tscn")
	GlobalVariables.SetupComplete.connect(Setup)

func GameAboutToBeSaved():
	#This is a fix for a bug where if the player saves while the ghost is carrying an ore 
	#- the ore will not be saved.
	#This code tells the ghost to immediately drop the ore in its rightful place, ready to be saved
	
	if ghostSpawned:
		ghostInScene.GameIsBeingSaved()
	
	pass

func Setup():
	var inventory:inventory_handler=HUD.HUD_InventoryManager
	inventory.signal_pickedUpHeart.connect(HeartPickedUpByPlayer)
	
	orespawner=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	orespawner.signal_heartSpawned.connect(HeartSpawned)
	

func HeartSpawned(heart:Node2D):
	if !GlobalVariables.ghostActive:
		return
	#TODO - make sure rightful place is considered nest
	
	await get_tree().create_timer(0.1).timeout
	
	#The heart will despawn when given to the egg
	if heart==null:
		if ghostSpawned:
			ghostInScene.Disappear(false)
		return
	
	for body in HeartRightfulPlace.get_overlapping_bodies():
		if body.GetOre().ID==10:		
			if ghostSpawned:
				ghostInScene.Disappear(true)
				
			return
	
	#TODO: Ghost should not persue player, only get the heart and return home with it <3 
	if !ghostSpawned:
		SpawnGhost()
	
	ghostInScene.PlayerDroppedHeartInUnproperPlace(heart)
	
	pass
	
func DropHeartInRightfulPlace():
	
	orespawner.SpawnOreAtLocation(HeartRightfulPlace.global_position,heartOreReference,Vector2(0,0),false,true)
	

func HeartPickedUpByPlayer():
	if !GlobalVariables.ghostActive:
		return
		
	for bod in ghostAcceptanceArea.get_overlapping_bodies():
		return
	
	if !ghostSpawned:
		SpawnGhost()
		
		
		#Spawn text bubble lol
		var node:text_bubble=textBubblePath.instantiate()
		add_child(node)
		node.Setup(abstract_textEffect.effectEnum.WAVE,text_bubble.behaviourEnum.FADE)
		node.ShowText("How dare you..!")
		node.position=$warningLocation.position
	
	ghostInScene.PlayerPickedUpHeart()
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !GlobalVariables.ghostActive:
			return
	if ghostIsComing and !ghostSpawned:
		ghostTimeCounter+=delta
		if ghostTimeCounter>TimeBeforeGhostComes:
			SpawnGhost()
			ghostIsComing=false
	pass
	
	
func playerLightStatusChanged():
	if GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.LIT_EXTERNALLY:
		ghostIsComing=false
		pass
		#DespawnGhost()
	
	if !ghostSpawned && GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.DARK:
		if !ghostIsComing:
			ghostIsComing=true
			TimeBeforeGhostComes=randf_range(minTimeBeforeGhostSpawns,maxTimeBeforeGhostSpawns)
			
		#spawn ghost
	
func SpawnGhost():
	ghostSpawned=true
	ghostInScene = ghostRef.instantiate()
	$"..".add_child(ghostInScene)
	ghostInScene.position=player.global_position+Vector2(randi_range(-50,50),randi_range(130,200))
	ghostInScene.GiveParentReference(self)
	ghostInScene.NewHaunting(player)
	
	pass

func GhostHasDespawned():
	ghostInScene=null
	ghostSpawned=false
