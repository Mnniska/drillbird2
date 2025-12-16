extends Node2D
class_name water_piece

var mySpawnedWater:water_piece=null
var mySpawnedWater_splitterOffshoot:water_piece=null

signal GettingDestroyed
signal FallingWaterSpawned(water_piece)

enum dir{right,left,up,down}
var myDir:dir=dir.right
enum waterType{falling,horizontal,splitter}
var myType:waterType=waterType.falling

var isWaitingToSpreadAdditionalTendril:bool=false

@export var waterSpreadLength:int=2
@onready var observer=preload("res://Scenes/observer.tscn")


var HP:int=1:
	get:
		return HP
	set(value):
		HP=value


@onready var debugtext=$"debug A"
@onready var waterScene=preload("res://Scenes/Water shenanigans/WaterPiece.tscn")

@onready var sprite=$"Water anim"
@export var timeBeforeSplitterSendsAdditionalTendril:float=0.5
var chosenDirectionForSplitter:dir=dir.up #Not implementeddd



var tilemap:TileMapLayer
var posInTilemap:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap=GlobalVariables.MainSceneReferenceConnector.ref_environmentTilemap
	var obs:observerScript = observer.instantiate()
				
	obs.BlockDestroyed.connect(SelfOff)
	
	obs.transform.origin=Vector2(0,16)
	add_child(obs)

func SetupCheck(_type:waterType,_direction:dir,_hp:int=3):
	HP=_hp
	myType=_type
	myDir=_direction
	
	
	var text
	match myDir:
		dir.left:
			text="left"
		dir.right:
			text="right"
		dir.down:
			text="down"
		dir.up:
			text="up"
	
	debugtext.text=text
	
	posInTilemap= tilemap.local_to_map(tilemap.to_local(global_position))


	SetupAnim()
	if _type==waterType.falling:
		FallingWaterSpawned.emit(self)
	
	await get_tree().create_timer(0.2).timeout
	
	CheckWhichWaterToSpawn()



func CheckWhichWaterToSpawn():
	match myType:
		waterType.falling:
			if(!IsThereBlockInDirection(dir.down)):
				if IsThereBlockInDirection(dir.down,true):
					SpawnWaterBlock(dir.down,waterType.splitter)
				else:
					SpawnWaterBlock(dir.down,waterType.falling)
		waterType.horizontal:
			
			if IsThereBlockInDirection(myDir):
				if HP<1:
					pass
					#There's a wall, so water should splash against it
			else:
				#Is there a block under the block I wanna go to? 
				#If so, spawn a horizontal water blok with -1 HP
				if IsThereBlockInDirection(myDir,true):
					
					#if water can extend longer, spawn block with 1 less HP
					if HP>0:
						SpawnWaterBlock(myDir,waterType.horizontal,HP-1)
				else:
					if HP>0:
						SpawnWaterBlock(myDir,waterType.falling)
			
		waterType.splitter:

			HandleSplitter()

func SetupAnim():
	match myType:
		waterType.falling:
			sprite.animation="falling"
		waterType.splitter:
			sprite.animation="split"
		waterType.horizontal:
			if myDir==dir.right:
				sprite.animation="hori_right"
			if myDir==dir.left:
				sprite.animation="hori_left"
	pass

func HandleSplitter():
	
	if !IsThereBlockInDirection(myDir):
		if IsThereBlockInDirection(myDir,true):
			SpawnWaterBlock(myDir,waterType.horizontal,waterSpreadLength)
		else:
			SpawnWaterBlock(myDir,waterType.falling)
	
	isWaitingToSpreadAdditionalTendril=true
	await get_tree().create_timer(timeBeforeSplitterSendsAdditionalTendril).timeout
	#The isWaitingToSpreadAdditionalTendril bool is set if a FALLING water piece is spawned further down in the chain - meaning this additional tendril is not needed
	if !isWaitingToSpreadAdditionalTendril:
		return
	
	isWaitingToSpreadAdditionalTendril=false
	
	var dirOpposite=GetOppositeDir(myDir)

	#todo: If the splitter notices that one of the horizontal blocks has spawned a faller, it should abort the other path immediately
	
	if !IsThereBlockInDirection(dirOpposite):
		if IsThereBlockInDirection(dirOpposite,true):
			#Reverses direction of water block since it's changed dir
			SpawnWaterBlock(dirOpposite,waterType.horizontal,waterSpreadLength-1,true)
		else:
			SpawnWaterBlock(dirOpposite,waterType.falling,HP,true)
	
func DespawnWaterChild(killoffshoot:bool):
	if killoffshoot:
		if mySpawnedWater_splitterOffshoot!=null:
			mySpawnedWater_splitterOffshoot.SourceOff(false)
			mySpawnedWater_splitterOffshoot=null	
	else:
		if mySpawnedWater!=null:
			mySpawnedWater.SourceOff(false)
			mySpawnedWater=null

func ChildSpawnedFallWater(WaterThatSpawnedFaller:water_piece):
	
	match myType:
		waterType.horizontal:
			FallingWaterSpawned.emit(self)
		waterType.splitter:
			
			#Used in Handle splitter function to not send more tendrils out
			isWaitingToSpreadAdditionalTendril=false
			
			
			if WaterThatSpawnedFaller.global_position.x > global_position.x:
				if myDir==dir.right:
					DespawnWaterChild(true)
					#water is to the right, and mydir is to the right 
				elif myDir==dir.left:
					DespawnWaterChild(false)
			else:
				if myDir==dir.right:
					DespawnWaterChild(false)
					#water is to the right, and mydir is to the right 
				elif myDir==dir.left:
					DespawnWaterChild(true)
			

				
	
	#Is the water that spawned in the splitters direction?
	
	#TODO: 
	#Check if child is in direction of splitter's direction
	#If so - tell the opposite dir child that source has dried up 
	#Do opposite if opposite is true
	#Also need to save both childrens references when spawning children using splitters
	
	pass

func SpawnWaterBlock(directionRelativeToParent:dir,childType:waterType,HP:int=3,inverseDir:bool=false):
	var node:water_piece=waterScene.instantiate()
	
	#This variable is used to subscribe to if the water block dies, and to call it if THIS water block dies
	
	
	#assumes direction only inverses at splitter nodes
	#Saved so that splitter can destroy the offshoot that does not spawn a faller
	if inverseDir:
		mySpawnedWater_splitterOffshoot=node
		mySpawnedWater_splitterOffshoot.GettingDestroyed.connect(NextOff)
		mySpawnedWater_splitterOffshoot.FallingWaterSpawned.connect(ChildSpawnedFallWater)
	else:
		mySpawnedWater=node
	
		mySpawnedWater.GettingDestroyed.connect(NextOff)
		mySpawnedWater.FallingWaterSpawned.connect(ChildSpawnedFallWater)
	
	var differingPos:Vector2
	
	match directionRelativeToParent:
		dir.right:
			differingPos=Vector2(16,0)
		dir.left:
			differingPos=Vector2(-16,0)
		dir.up:
			pass
			#This should never happen lol 
		dir.down:
			differingPos=Vector2(0,16)
	
	#handle this in child instead? Or..hmm
	#If I handle it here, gotta account for splitter interrupting itself. 
	#fuck it lets handle it in child
			#FallingWaterSpawned.emit(self)
			

	
	get_parent().add_child(node)
	node.position=self.position+differingPos
	
	var _dir=myDir
	if inverseDir:
		_dir=!dir
	
	node.SetupCheck(childType,_dir,HP)


#	node.position=global_position+GlobalVariables.get
	
	pass



func SourceOff(ShouldDoCallout:bool=true):
	#The block powering this block has been turned off
	#Wait 0.2 seconds, turn self off, then queue free
	await get_tree().create_timer(0.1).timeout
	SelfOff(ShouldDoCallout)
	
	pass

func NextOff():
	#The next water source has been turned off
	#Do a raycast to see what is next, then spawn a new water piece as correct type
	
	#todo: probably not the best call, need to investigate :) 
	CheckWhichWaterToSpawn()
	
	pass

func SelfOff(ShouldDoCallout:bool=true):
	#This piece becomes crushed or turned off by floor disappearing. 
	#Destroy self
	
	if mySpawnedWater!=null:
		mySpawnedWater.SourceOff()
	
	if mySpawnedWater_splitterOffshoot!=null:
		mySpawnedWater_splitterOffshoot.SourceOff()
	
	if ShouldDoCallout:
		GettingDestroyed.emit()
	
	queue_free()
	
	pass
	
	
func GetOppositeDir(_dir:dir)->dir:
	match _dir:
		dir.up:
			return dir.down
		dir.down:
			return dir.up
		dir.left:
			return dir.right
		dir.right:
			return dir.left
	
	return dir.right
	
func IsThereBlockInDirection(direction:dir,checkBelow:bool=false)->bool:
	#Uses a raycast to check if there's a block in the given direction
	#Could also set up a reference to the tilemap and ask it if there's anything there - maybe that's a bit more efficient? 
	#Let's do raycast for now and see how it does :thumbup: 
	
	var adder:Vector2i=Vector2i(0,0)
	match direction:
		dir.right:
			adder=Vector2i(1,0)
		dir.left:
			adder=Vector2i(-1,0)
		dir.down:
			adder=Vector2i(0,1)
		dir.up:
			adder=Vector2i(1,-1)
	
	if checkBelow:
		adder+=Vector2i(0,1)
	
	if tilemap.get_cell_tile_data(posInTilemap+adder):
		#Does not account for fall blocks atm, whateveaaaa
		return true
	
	return false
