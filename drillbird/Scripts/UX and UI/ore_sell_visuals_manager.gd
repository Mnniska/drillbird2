extends Node2D

signal isSellingChanged(isSelling:bool)

var oreVisual = preload("res://Scenes/Effects/ore_sell_visualizer.tscn")

var oreSellLocations:Array[sell_location_script]



@onready var PlayerXPGainFeedback=$"../PlayerXPGainedVisualizer"
@onready var playerXPTextBubble:text_bubble_xp=$"../PlayerXPGainedVisualizer/oreXPCollider_PLAYER/TextBubbleXP"
var playerXPGainedThisSell:int=0
var targetXPGainedThisSell:int=0


var oreVisualsArray:Array[Node2D] #ReplaceWithOreVisualsLater
var xpVisualsArray_toEgg:Array[Node2D] #ReplaceWithXPVisualsLater!
var xpVisualsArray_toPlayer:Array[Node2D] #ReplaceWithXPVisualsLater!
var playerRef:CharacterBody2D

var isSelling:bool=false:
	get: return isSelling
	set(value): 
		isSelling=value
		isSellingChanged.emit(isSelling)
var xpFollowPlayer:bool=false

var oresSoldThisRound:int=0
@export var minPitchWhenSelling:float=1


@onready var birdySleepPos=$"../Eggs/BirdySleepPositions/birdySleep"
@onready var EggBase=$"../Eggs"

@export var eggXPGainVisualMultiplier:float=3

var oresBeingSold:int=0
@export var TimeToSellAnOre:float=2.5

var orestosell:Array[abstract_ore]

func _ready() -> void:
	var oresellnodes = $NodePositions.get_children()
	for n in oresellnodes:
		oreSellLocations.append(n)


func OreFinishedSelling(amount:int):
	oresBeingSold-=1

	var pitchJump=0.05
	var pitch=minPitchWhenSelling+pitchJump*(oresSoldThisRound-oresBeingSold)
	
	SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_GIVEORE_POFF,pitch)
	
	if oresBeingSold<0:
		oresBeingSold=0
	
	if oresBeingSold==0:
		isSelling=false
		oresSoldThisRound=0
	
	
func _process(delta: float) -> void:
	if !xpFollowPlayer:
		return
	
	if playerRef!=null:
		PlayerXPGainFeedback.global_position=playerRef.global_position

func SellThisOre(ore:abstract_ore,_oreBodyReference:Node2D):
	
	if !isSelling:
		isSelling=true
		oresSoldThisRound=0
	oresSoldThisRound+=1
	oresBeingSold+=1
	#Assumes it takes TimeToSellAndOre amount of seconds to sell an ore, will then set itself as not selling
	
	var chosenLocation:sell_location_script
	var index=0
	for n in oreSellLocations:
		if n.available:
			chosenLocation=n
			break
		index+=1
	if chosenLocation==null:
		chosenLocation=oreSellLocations[0]
	chosenLocation.BeginSellingOre(TimeToSellAnOre)
	
	var oreSellVisualizer:ore_sell_visualizer=oreVisual.instantiate()
	add_child(oreSellVisualizer)
	oreSellVisualizer.finishedSelling.connect(OreFinishedSelling)

	print_debug(str(index))
	var timetoSell:float=0.2
	oreSellVisualizer.Setup(ore,chosenLocation.global_position,1+(index*timetoSell))
	oreSellVisualizer.global_position=_oreBodyReference.global_position
	return oreSellVisualizer
	
