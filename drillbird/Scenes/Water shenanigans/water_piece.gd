extends Node2D
class_name water_piece



enum dir{right,left,up,down}
var myDir:dir=dir.right
enum waterType{falling,horizontal,splitter}
var myType:waterType=waterType.falling
var HP:int=1:
	get:
		return HP
	set(value):
		HP=value
		debugtext.text=str(HP)


@onready var debugtext=$"debug A"
@onready var waterScene=preload("res://Scenes/Water shenanigans/WaterPiece.tscn")

@onready var sprite=$"Water anim"
@export var timeBeforeSplitterSendsAdditionalTendril:float=0.5
var chosenDirectionForSplitter:dir=dir.up #Not implementeddd

signal GettingDestroyed

var tilemap:TileMapLayer
var posInTilemap:Vector2i

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tilemap=GlobalVariables.MainSceneReferenceConnector.ref_environmentTilemap

func SetupCheck(_type:waterType,_direction:dir,_hp:int=3):
	HP=_hp
	myType=_type
	myDir=_direction
	posInTilemap= tilemap.local_to_map(tilemap.to_local(global_position))

	SetupAnim()
	
	
	await get_tree().create_timer(0.2).timeout
	
	match myType:
		waterType.falling:
			if(!IsThereBlockInDirection(dir.down)):
				if IsThereBlockInDirection(dir.down,true):
					SpawnWaterBlock(myDir,waterType.splitter)
				else:
					SpawnWaterBlock(myDir,waterType.falling)
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
			SpawnWaterBlock(myDir,waterType.horizontal,3)
		else:
			SpawnWaterBlock(myDir,waterType.falling)
	
	await get_tree().create_timer(timeBeforeSplitterSendsAdditionalTendril).timeout
	#Bug: If something happens during timer, it should be interrupted
	
	var dirOpposite=GetOppositeDir(myDir)

	#todo: If the splitter notices that one of the horizontal blocks has spawned a faller, it should abort the other path immediately
	
	if !IsThereBlockInDirection(dirOpposite):
		if IsThereBlockInDirection(dirOpposite,true):
			SpawnWaterBlock(dirOpposite,waterType.falling)
		else:
			SpawnWaterBlock(dirOpposite,waterType.horizontal,2)
	
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

func SpawnWaterBlock(direction:dir,type:waterType,HP:int=3):
	var node:water_piece=waterScene.instantiate()
	
	var differingPos:Vector2
	
	match type:
		waterType.horizontal:
			if myDir==dir.right:
				differingPos=Vector2(16,0)
			if myDir==dir.left:
				differingPos=Vector2(-16,0)
		waterType.splitter:
			differingPos=Vector2(0,16)
		waterType.falling:
			if myType==waterType.falling:
				differingPos=Vector2(0,16)
			if myType==waterType.horizontal or myType==waterType.splitter:
				if myDir==dir.right:
					differingPos=Vector2(16,0)
				if myDir==dir.left:
					differingPos=Vector2(-16,0)
			

	
	get_parent().add_child(node)
	node.position=self.position+differingPos
	node.SetupCheck(type,direction,HP)


#	node.position=global_position+GlobalVariables.get
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

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
	

func SourceOff():
	#The block powering this block has been turned off
	#Wait 0.2 seconds, turn self off, then queue free
	
	pass

func NextOff():
	#The next water source has been turned off
	#Do a raycast to see what is next, then spawn a new water piece as correct type
	
	pass

func SelfOff():
	#This piece becomes crushed or turned off by floor disappearing. 
	#Destroy self
	
	pass
