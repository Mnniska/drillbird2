extends Node2D
class_name demon_manager

var ghostRef
var ghostInScene:ghost
var ghostSpawned:bool=false
var player
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
	
	GlobalVariables.MainSceneReferenceConnector.mainScene.signal_GameAboutToBeSaved.connect(GameAboutToBeSaved)
	GlobalVariables.playerLightStatusChange.connect(playerLightStatusChanged)
	ghostRef=preload("res://Scenes/Objects and Enemies/ghost.tscn")
	GlobalVariables.SetupComplete.connect(Setup)
	GlobalVariables.GameIsBeingReset.connect(GameAboutToBeSaved)

func GameAboutToBeSaved():
	#This is a fix for a bug where if the player saves while the ghost is carrying an ore 
	#- the ore will not be saved.
	#This code tells the ghost to immediately drop the ore in its rightful place, ready to be saved
	
	if ghostSpawned:
		ghostInScene.GameIsBeingSaved()
	
	pass

func Setup():
	
	player=GlobalVariables.PlayerController

	var inventory:inventory_handler=HUD.HUD_InventoryManager
	inventory.signal_pickedUpSoul.connect(SoulPickedUpByPlayer)
	
	orespawner=GlobalVariables.MainSceneReferenceConnector.ref_oreTilemap
	orespawner.signal_soulSpawned.connect(SoulSpawned)
	

func SoulSpawned(heart:Node2D):
	if !GlobalVariables.demonActive:
		return
	
	await get_tree().create_timer(0.1).timeout
	
	#The heart will despawn when given to the egg
	if heart==null:
		if ghostSpawned:
			ghostInScene.Disappear(false)
		return
	
	#The ghost checks if the heart is in a nice place. If so, it despawns itself and ends the haunt. 
	for body in HeartRightfulPlace.get_overlapping_bodies():
		if body.GetOre().ID==11:		
			if ghostSpawned:
				ghostInScene.Disappear(true)
				
			return
	
	#if the heart is spawned in an unproper place, the ghost will come and attempt to retreive it 
	if !ghostSpawned:
		SpawnDemon()
	ghostInScene.PlayerDroppedHeartInUnproperPlace(heart)
	heart.SetStressed(true)
	
	pass
	
func DropHeartInRightfulPlace():
	
	orespawner.SpawnOreAtLocation(HeartRightfulPlace.global_position,heartOreReference,Vector2(0,0),false,true)
	

func SoulPickedUpByPlayer():
	if !GlobalVariables.demonActive:
		return
		
	#if the player picks up the heart in the nest - ghost will ignore it
	for bod in ghostAcceptanceArea.get_overlapping_bodies():
		return
	
	if !ghostSpawned:
		SpawnDemon()
		
		
		#Spawn text bubble lol
		var node:text_bubble=textBubblePath.instantiate()
		add_child(node)
		node.Setup(abstract_textEffect.effectEnum.WAVE,text_bubble.behaviourEnum.FADE)
		node.ShowText(tr("popup_ghost_bark"))
		node.position=$warningLocation.position
	
	ghostInScene.PlayerPickedUpHeart()
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
	
func SpawnDemon():
	ghostSpawned=true
	ghostInScene = ghostRef.instantiate()
	$"..".add_child(ghostInScene)
	ghostInScene.position=player.global_position+Vector2(randi_range(-50,50),randi_range(130,200))
	ghostInScene.GiveParentReference(self,true)
	ghostInScene.NewHaunting(player)
	
	pass

func GhostHasDespawned(): #called from the ghost object when despawning itself. Needs to be done there since it reacts to light
	ghostInScene=null
	ghostSpawned=false
