extends Node2D
class_name camera_limiter

@export var respawnPoint:Node2D
@export var respawnPlayerWhenOutOfZone:bool=false

@export var limit_top:bool=false
@export var limit_bottom:bool=false
@export var limit_right:bool=false
@export var limit_left:bool=false

var cameraOffsetHorizontal=320/2
var cameraOffsetVertical=224/2

var player:Node2D

var boundingBoxBegin:Vector2
var boundingBoxEnd:Vector2
var rectSize:Vector2
var average:float

var detectTimeCounter:float=0
var detectingPlayer:bool=false
var detectTime:float=0.05
var active:bool=false


func _ready() -> void:
	
	rectSize = $AffectedArea/CollisionShape2D.shape.size
	average = (rectSize.x/2+rectSize.y/2)/2
	boundingBoxBegin =global_position-Vector2(rectSize.x/2,rectSize.y/2)
	boundingBoxEnd =global_position+Vector2(rectSize.x/2,rectSize.y/2)
	
	GlobalVariables.SetupComplete.connect(SetupComplete)

func SetupComplete():
	player=GlobalVariables.PlayerController
	pass

func SetActive(detected:bool):
	if active==detected:
		return
	active=detected
	var camera:Camera2D=GlobalVariables.MainSceneReferenceConnector.camera
	

	
	if active:
		if limit_left:
			camera.limit_left=boundingBoxBegin.x
			
		if limit_right:
			camera.limit_right=boundingBoxEnd.x
			
		if limit_bottom:
			camera.limit_bottom=boundingBoxEnd.y

		if limit_top:
			camera.limit_top=boundingBoxBegin.y
	
	if !active:
		var bigNum=10000000
		camera.limit_bottom=bigNum
		camera.limit_left=-bigNum
		camera.limit_right=bigNum
		camera.limit_top=-bigNum


#Tools for sensing whether player is in the area or not. I've added delays to circumvent area2Ds incorrectly registering extra exits/entrances
func _process(delta: float) -> void:
	
	if detectingPlayer:
		detectTimeCounter= min(detectTime,detectTimeCounter+delta)
		if detectTimeCounter>=detectTime:
			SetActive(true)
	else:
		detectTimeCounter=max(0,detectTimeCounter-delta)
		if detectTimeCounter<=0:
			SetActive(false)
	
		
	
	
	if player==null:
		return

	if player!=null:
		var playerpos=player.global_position
		var posx=playerpos.x
		var posy=playerpos.y
		if playerpos.x<boundingBoxBegin.x:
			posx=boundingBoxBegin.x
		if playerpos.x>boundingBoxEnd.x:
			posx=boundingBoxEnd.x
			
		if playerpos.y>boundingBoxEnd.y:
			posy=boundingBoxEnd.y
		if playerpos.y<boundingBoxBegin.y:
			posy=boundingBoxBegin.y
			
		#audioplayer.global_position=Vector2(posx,posy)


func _on_affected_area_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	detectingPlayer=true
	pass # Replace with function body.


func _on_affected_area_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	detectingPlayer=false
	pass # Replace with function body.
