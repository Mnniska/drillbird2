extends Node2D

signal finishedSelling

var oreVisual = preload("res://Scenes/Effects/ore_sell_visualizer.tscn")
var xpVisual=preload("res://Scenes/Effects/xp_visualizer.tscn")
@onready var OreSellLocations=$NodePositions.get_children()
@onready var oreXPCollider=$"../oreXPCollider"


@onready var PlayerXPGainFeedback=$"../PlayerXPGainedVisualizer"
@onready var playerXPTextBubble:text_bubble_xp=$"../PlayerXPGainedVisualizer/oreXPCollider_PLAYER/TextBubbleXP"
var playerXPGainedThisSell:int=0
var targetXPGainedThisSell:int=0


var oreVisualsArray:Array[Node2D] #ReplaceWithOreVisualsLater
var xpVisualsArray_toEgg:Array[Node2D] #ReplaceWithXPVisualsLater!
var xpVisualsArray_toPlayer:Array[Node2D] #ReplaceWithXPVisualsLater!
var playerRef:CharacterBody2D

var isSelling:bool=false
var xpFollowPlayer:bool=false



@onready var birdySleepPos=$"../Eggs/BirdySleepPositions/birdySleep"
@onready var EggBase=$"../Eggs"

@export var eggXPGainVisualMultiplier:float=3

var orestosell:Array[abstract_ore]

func _process(delta: float) -> void:
	if !xpFollowPlayer:
		return
	
	if playerRef!=null:
		PlayerXPGainFeedback.global_position=playerRef.global_position

func SellTheseOres(ores:Array[abstract_ore],_playerReference:CharacterBody2D):
	xpFollowPlayer=true

	isSelling=true
	orestosell=ores
	playerRef=_playerReference
	playerXPTextBubble.Setup(abstract_textEffect.effectEnum.WAVE,text_bubble.behaviourEnum.FADE)
	playerXPTextBubble.DestroyAfterFadingOut=false
	playerXPTextBubble.UseTypewriteEffect=false
	
	playerXPGainedThisSell=0
	targetXPGainedThisSell=0
	
	#Spawns visual ores based on what was given
	var i=0
	for ore in orestosell:
		var node:ore_sell_visualizer = oreVisual.instantiate()

		add_child(node)
		node.global_position=_playerReference.global_position
		node.Setup(ore)

		node.StartMoveToPosition(OreSellLocations[ min(i,OreSellLocations.size()-1) ].global_position)
		oreVisualsArray.append(node)
		i+=1
	
	await get_tree().create_timer(1.2).timeout
	
	
	for vOre in oreVisualsArray:
		var xpCount:int=0
		var orepos=vOre.global_position
		var xpAmount=vOre.SellSelf()
		for n in xpAmount*eggXPGainVisualMultiplier:
			
			var node=xpVisual.instantiate()
			var offsetSize=3
			var offset=Vector2(randf_range(-offsetSize,offsetSize),randf_range(-offsetSize,offsetSize))
			
			add_child(node)
			node.global_position=orepos +offset

			xpCount+=1
			if xpCount<=xpAmount:
				targetXPGainedThisSell+=1
				xpVisualsArray_toPlayer.append(node)
			else:
				xpVisualsArray_toEgg.append(node)
				
		await get_tree().create_timer(0.15).timeout

	


	
	await get_tree().create_timer(0.5).timeout

	
	var EggCenterPos=Vector2(EggBase.global_position.x,  EggBase.global_position.y-abs((birdySleepPos.global_position.y-EggBase.global_position.y)/2))
	oreXPCollider.global_position=EggCenterPos
	for xpOrb in xpVisualsArray_toEgg:
		xpOrb.MoveToPosition(EggCenterPos)
	
	await get_tree().create_timer(1).timeout

	for xpOrb in xpVisualsArray_toPlayer:
		xpOrb.MoveToObject(playerRef)

	await get_tree().create_timer(0.5).timeout
	
	oreVisualsArray.clear()
	xpVisualsArray_toPlayer.clear()
	xpVisualsArray_toEgg.clear()
	
	
	return true

func XPFeedbackFinishedDisplaying():
	xpFollowPlayer=false

func _on_ore_xp_collider_player_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if !area.get_parent().MovingToObject:
		return
	
	area.get_parent().queue_free()
	
	playerXPGainedThisSell+=1
	playerXPTextBubble.ShowText("+ "+str(playerXPGainedThisSell)+" xp!")
	
	if playerXPGainedThisSell>=targetXPGainedThisSell:
		isSelling=false
		finishedSelling.emit()
	
