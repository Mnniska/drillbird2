extends Node2D
class_name water_piece

var mySpawnedWater:water_piece=null
var mySpawnedWater_splitterOffshoot:water_piece=null
var myObserver_original:observerScript #These bad bois are used by horizontal and splitter water to listen to if terrain breaks. I am saving them as variables because the splitter needs to unsubscribe to an observer once an offshoot spawns falling water
var myObserver_offshoot:observerScript

signal GettingDestroyed(water_piece)
signal FirstFallerSpawned(water_piece)

enum dir{right,left,up,down}
var myDir:dir=dir.right
enum waterType{falling,horizontal,splitter}
var myType:waterType=waterType.falling
var isFirstFallerTile:bool=false
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
	

func SetupCheck(_type:waterType,_direction:dir,_hp:int=3,firstFaller:bool=false):
	HP=_hp
	myType=_type
	myDir=_direction
	isFirstFallerTile=firstFaller
	
	if firstFaller:
		FirstFallerSpawned.emit(self)
	
	if myType!=waterType.falling:
		var obs:observerScript = observer.instantiate()
		obs.BlockDestroyed.connect(SelfOff)
		obs.transform.origin=Vector2(0,16)
		add_child(obs)
	
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


	
	await get_tree().create_timer(0.2).timeout
	
	CheckWhichWaterToSpawn()



func CheckWhichWaterToSpawn():
	match myType:
		waterType.falling:
			if(!IsThereBlockInDirection(dir.down)):
				if IsThereBlockInDirection(dir.down,Vector2i(0,1)):
					SpawnWaterBlock(dir.down,waterType.splitter)
				else:
					SpawnWaterBlock(dir.down,waterType.falling)
		waterType.horizontal:
			
			if IsThereBlockInDirection(myDir):
				if HP>0:
					SpawnObserver(myDir)
					#There's a wall, so water should splash against it
			else:
				#Is there a block under the block I wanna go to? 
				#If so, spawn a horizontal water blok with -1 HP
				if IsThereBlockInDirection(myDir,Vector2i(0,1)):
					
					#if water can extend longer, spawn block with 1 less HP
					if HP>0:
						SpawnWaterBlock(myDir,waterType.horizontal,HP-1)
				else:
					if HP>0:
						#Is there a block UNDER the faller block? If so, spawn a splitter instead
						if IsThereBlockInDirection(myDir,Vector2i(0,2)):
							SpawnWaterBlock(myDir,waterType.splitter)
						else:
							SpawnWaterBlock(myDir,waterType.falling)
			
		waterType.splitter:

			HandleSplitter()

func SetupAnim():
	match myType:
		waterType.falling:
			
			if isFirstFallerTile:
				sprite.animation="down_side"
			else:
				sprite.animation="falling"
			
		waterType.splitter:
			if isFirstFallerTile:
				sprite.animation="split_side"
			else:
				sprite.animation="split"
		waterType.horizontal:
			sprite.animation="hori_right"

	if myDir==dir.right:
		sprite.scale=Vector2(1,1)

	if myDir==dir.left:
		sprite.scale=Vector2(-1,1)


func HandleSplitter():

	isWaitingToSpreadAdditionalTendril=true
	
	#If it hasn't already spawned a water in waters dir, spawn one
	if mySpawnedWater==null:
		
		if !IsThereBlockInDirection(myDir):
			if IsThereBlockInDirection(myDir,Vector2i(0,1)):
				SpawnWaterBlock(myDir,waterType.horizontal,waterSpreadLength)
			else:
				if IsThereBlockInDirection(myDir,Vector2i(0,2)):
					SpawnWaterBlock(myDir,waterType.splitter)
					
				else:
					SpawnWaterBlock(myDir,waterType.falling)
		else:
			#todo: account for other tendril getting fulfilled
			SpawnObserver(myDir)

	await get_tree().create_timer(timeBeforeSplitterSendsAdditionalTendril).timeout
	#The isWaitingToSpreadAdditionalTendril bool is set if a FALLING water piece is spawned further down in the chain - meaning this additional tendril is not needed
	if !isWaitingToSpreadAdditionalTendril:
		return
	
	isWaitingToSpreadAdditionalTendril=false
	
	var dirOpposite=GetOppositeDir(myDir)

	#todo: If the splitter notices that one of the horizontal blocks has spawned a faller, it should abort the other path immediately
	
	if mySpawnedWater_splitterOffshoot==null:
		if !IsThereBlockInDirection(dirOpposite):
			if IsThereBlockInDirection(dirOpposite,Vector2i(0,1)):
				#Reverses direction of water block since it's changed dir
				SpawnWaterBlock(dirOpposite,waterType.horizontal,waterSpreadLength-1,true)
			else:
				if IsThereBlockInDirection(dirOpposite,Vector2i(0,2)):
					SpawnWaterBlock(dirOpposite,waterType.splitter,HP,true)
					
				else:
					SpawnWaterBlock(dirOpposite,waterType.falling,HP,true)
		else:
			SpawnObserver(dirOpposite,true)
var timesDespawnedWaterChild:int=0
func DespawnWaterChild(killoffshoot:bool):
	timesDespawnedWaterChild+=1
	
	debugtext.text=str(timesDespawnedWaterChild)
	
	if killoffshoot:
		if mySpawnedWater_splitterOffshoot!=null:
			mySpawnedWater_splitterOffshoot.SourceOff(false)
			mySpawnedWater_splitterOffshoot=null	
		if myObserver_offshoot!=null:
			myObserver_offshoot.BlockDestroyed.disconnect(ObserverTriggered)
			myObserver_offshoot.queue_free()
	else:
		if mySpawnedWater!=null:
			mySpawnedWater.SourceOff(false)
			mySpawnedWater=null
		if myObserver_original!=null:
			myObserver_original.BlockDestroyed.disconnect(ObserverTriggered)
			myObserver_original.queue_free()

func ChildSpawnedFallWater(WaterThatSpawnedFaller:water_piece):
	
	match myType:
		waterType.horizontal:
			FirstFallerSpawned.emit(self)
		waterType.splitter:
			
			#Used in Handle splitter function to not send more tendrils out
			isWaitingToSpreadAdditionalTendril=false
			
			#Direction can only be left/right
			#if dir of splitter matches child, it means that the offshoot should be killed
			if myDir==WaterThatSpawnedFaller.myDir:
				DespawnWaterChild(true)
			else:
				DespawnWaterChild(false)
			

			

func ObserverTriggered():
	
	CheckWhichWaterToSpawn()
	pass

func SpawnObserver(positionRelativeToWater:dir,isOffshoot:bool=false):
	
	#Debug!! 
	return
	
	var obs:observerScript = observer.instantiate()
	obs.BlockDestroyed.connect(ObserverTriggered)
	
	

	
	var offset:Vector2=Vector2(16,0)
	match positionRelativeToWater:
		dir.up:
			offset=Vector2(0,-16)
		dir.down:
			offset=Vector2(0,16)
		dir.left:
			offset=Vector2(-16,0)
	
	obs.transform.origin=offset
	add_child(obs)
	
		#For some reason, destroying observers does not seem to work
	#Next focus sesh, let's investigate why that is 
	if isOffshoot:
		myObserver_offshoot=obs
	else:
		myObserver_original=obs

func SpawnWaterBlock(positionRelativeToparent:dir,childType:waterType,HP:int=3,inverseDir:bool=false):
	var node:water_piece=waterScene.instantiate()
	
	#This variable is used to subscribe to if the water block dies, and to call it if THIS water block dies
	
	
	#assumes direction only inverses at splitter nodes
	#Saved so that splitter can destroy the offshoot that does not spawn a faller
	if inverseDir:
		mySpawnedWater_splitterOffshoot=node
	else:
		mySpawnedWater=node
		
	node.GettingDestroyed.connect(NextOff)
	node.FirstFallerSpawned.connect(ChildSpawnedFallWater)
		#Will having multiple connections fuck some of these up for the splitter?
	
	var differingPos:Vector2
	
	match positionRelativeToparent:
		dir.right:
			differingPos=Vector2(16,0)
		dir.left:
			differingPos=Vector2(-16,0)
		dir.up:
			pass
			#This should never happen lol 
		dir.down:
			differingPos=Vector2(0,16)
	
	if myType!=waterType.horizontal:
		pass
	
	var isFirstFaller:bool=false
	if myType!=waterType.falling:
		if childType==waterType.falling or childType==waterType.splitter:
			isFirstFaller=true
		
	#Position first fallers one step down, skipping a step
	if isFirstFaller:
		differingPos+=Vector2(0,16)
	

			

	
	get_parent().add_child(node)
	node.position=self.position+differingPos	

	#This is what causes issues - there's a "direction relative to parent"
	#Which is used to POSITION the child, but then therte's the 
	#water's inherit direction which is currently the same value. 
	#Atm the direction is set the same as "myDir" but it's a bit confusing 
	#let's differentiate the values	
	
	var _dir:dir=myDir
	if inverseDir:
		_dir=GetOppositeDir(_dir)
	node.SetupCheck(childType,_dir,HP,isFirstFaller)


#	node.position=global_position+GlobalVariables.get
	
	pass



func SourceOff(ShouldDoCallout:bool=true):
	#The block powering this block has been turned off
	#Wait 0.2 seconds, turn self off, then queue free
	await get_tree().create_timer(0.1).timeout
	SelfOff(ShouldDoCallout)
	
	pass

func NextOff(waterBeingDestroyed:water_piece):
	#The next water source has been turned off
	#Do a raycast to see what is next, then spawn a new water piece as correct type
	
	if myType==waterType.splitter:
		if waterBeingDestroyed==mySpawnedWater:
			mySpawnedWater=null
		if waterBeingDestroyed==mySpawnedWater_splitterOffshoot:
			mySpawnedWater_splitterOffshoot=null
	
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
		GettingDestroyed.emit(self)
	
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
	
func IsThereBlockInDirection(direction:dir,offset:Vector2i=Vector2i(0,0))->bool:
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
	

	adder+=offset
	
	if tilemap.get_cell_tile_data(posInTilemap+adder):
		#Does not account for fall blocks atm, whateveaaaa
		return true
	
	return false
