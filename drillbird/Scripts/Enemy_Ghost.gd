extends Node2D
class_name ghost
var hauntedObject:Node2D
var playerPos:Vector2

@onready var dissapointed_demon=preload("res://Scenes/Objects and Enemies/dissapointed_demon.tscn")

@export var MINSPEED:float=2
@export var MAXSPEED:float=6
@export var slowestSpeedDist:float=16*3
@export var fastestSpeedDist:float=16*6
@export var returnHearSpeedTime:float=4
@export var returnHearSpeedCount:float=0

@export var collType:abstract_collidable
var gamePaused:bool=false

#2.8
var  haunting:bool=false
var lastpos:Vector2
@onready var playerCollider=$PlayerChecker
@onready var anim=$sprite

var isCarryingHeart:bool=false
var musicProgress:float=0

var heart_misplaced:bool=true
var heart_playerHasHeart:bool=false

var parent:Node2D

var isPersuingHeart:bool=false
var isPlayingChaseMusic:bool=false
@export var idle_music:AudioStreamMP3
@export var chase_music:AudioStreamMP3
@onready var musicplayer=$GhostMusic

enum states{CHASE_PLAYER,CHASE_HEART,RETURN_HEART,DISAPPEARING}
var state:states=states.CHASE_PLAYER:
	set(value):state=value

var isDemon:bool=false

func GetCollType():
	return collType

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.signal_IsPlayerInMenuChanged.connect(SetGamePaused)
	musicplayer.finished.connect(musicplayer.play)
	pass # Replace with function body.

func UpdateMusic(chasing:bool):
	var ghost:AudioStreamPlayer2D =$GhostMusic
	if chasing:
		if ghost.bus!="Music":
			ghost.bus="Music"
		ghost.max_distance=1000
		ghost.stream=chase_music
		ghost.play()
	else:
		if ghost.bus!="Sfx":
			ghost.bus="Sfx"
		ghost.stream=idle_music
		ghost.play()
		ghost.max_distance=200
	

func SetGamePaused(paused:bool):
	gamePaused=paused

func UpdateState():
	
	if heart_playerHasHeart:
		state=states.CHASE_PLAYER
	elif heart_misplaced:
		state=states.CHASE_HEART
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if gamePaused:
		return
	match state:
		states.CHASE_PLAYER:
			if haunting && hauntedObject!=null:
				HauntObject(delta)
			pass
		states.CHASE_HEART:
			if haunting && hauntedObject!=null:
				HauntObject(delta)
			pass
		states.RETURN_HEART:
			if haunting && hauntedObject!=null:
				HauntObject(delta)			
		states.DISAPPEARING:
			
			pass
	

	pass

func GameIsBeingSaved():
	if state==states.RETURN_HEART:
		parent.DropHeartInRightfulPlace()
		isCarryingHeart=false
	Disappear()

func PlayerPickedUpHeart():
	NewHaunting(parent.player)
	state=states.CHASE_PLAYER
	UpdateMusic(true)
	pass

func PlayerDroppedHeartInUnproperPlace(heart:Node2D):
	NewHaunting(heart)
	state=states.CHASE_HEART
	UpdateMusic(false)
	pass

var velocity:Vector2=Vector2(0,0)

func HauntObject(delta:float):
	
	#This means that the heart has been picked up by the player, so ghost will follow them instead
	if hauntedObject==null:
		NewHaunting(parent.player)
	
	var speed=0
	var distanceToObject=self.global_position.distance_to(hauntedObject.global_position)
	
	if distanceToObject>fastestSpeedDist:
		speed=MAXSPEED
	
	if distanceToObject<fastestSpeedDist && distanceToObject>slowestSpeedDist:
		var progress=1-(distanceToObject-fastestSpeedDist)/(slowestSpeedDist-fastestSpeedDist)
		speed=MINSPEED+((MAXSPEED-MINSPEED)*progress)
	
	if distanceToObject<slowestSpeedDist:
		speed=MINSPEED

	var returnHeartMult:float=1
	if state==states.RETURN_HEART:
		returnHearSpeedCount = min(returnHearSpeedTime,returnHearSpeedCount + delta)
		returnHeartMult=0.2+3.8*(returnHearSpeedCount/returnHearSpeedTime)
	else:
		returnHearSpeedCount=0
	
	
	var directionVector=global_position - hauntedObject.global_position
	var normalizedDirectionVector=directionVector.normalized()
	var movementVector= normalizedDirectionVector*-1
	
	velocity=velocity.move_toward(speed*movementVector*returnHeartMult*delta*20,0.01)
	global_position+=velocity
	
	#global_position.x = move_toward(global_position.x, hauntedObject.global_position.x, s)
	#global_position.y = move_toward(global_position.y, hauntedObject.global_position.y, s)
	
	if lastpos.x-position.x<0:
		$sprite.flip_h=true
	else:
		$sprite.flip_h=false
	
	lastpos=Vector2(position.x,position.y)
	
	if state==states.CHASE_HEART:
		
		if distanceToObject<1:
			
			var oreToPickup:int=10
			if isDemon:oreToPickup=11
			
			if hauntedObject.GetOre().ID==oreToPickup:
				PickupHeart(hauntedObject)


	
	if state==states.RETURN_HEART:
		if distanceToObject<1:
			parent.DropHeartInRightfulPlace()
			isCarryingHeart=false
			
			#Update player light status so that ghost spawns again if it is dark
			if GlobalVariables.playerLightStatus==GlobalVariables.playerLightStatusEnum.DARK:
				NewHaunting(parent.player)
			else:
				Disappear()

func PickupHeart(heart:Node2D):
	state=states.RETURN_HEART
	isCarryingHeart=true
	
	if isDemon: #spawn a demon anim that is dissapointed, hopefully
		var node:Node2D=dissapointed_demon.instantiate()
		node.transform.origin=self.global_position
		get_parent().add_child(node)
	
	if isDemon:
		anim.animation="idle_demon_heart" #Demon turns into the ore escaping

	else:
		anim.animation="idle_heart"
		
	NewHaunting(parent.HeartRightfulPlace)
	heart.queue_free()

func CheckOverlappingCollisions():
	for n in playerCollider.get_overlapping_bodies():
		if !n==$".":
			n.DealDamage(1)
		pass
	
	pass

func DealDamage(amount:int):
	
	pass

func GiveParentReference(_parent:Node2D,_isDemon:bool=false):
	parent = _parent
	SetupDemon(_isDemon)
	pass

func SetupDemon(_isDemon:bool):
	isDemon=_isDemon
	if isDemon:
		anim.animation="demon_idle"
		anim.play()
	else:
		anim.animation="idle"
		anim.play()

func Disappear(useAnimation:bool=true):
	if state!=states.DISAPPEARING:
		parent.GhostHasDespawned()
		state=states.DISAPPEARING
		
		if useAnimation:
			if isDemon:
				anim.animation="demon_death"
			else:
				anim.animation="death"
			anim.play()
			
			#in theory awaits??
			var tween = get_tree().create_tween()
			tween.tween_property($GhostMusic, "volume_db", -50, 2)
			await get_tree().create_timer(2).timeout
		
		queue_free()

func NewHaunting(object:Node2D):
	hauntedObject=object
	haunting=true

func lerp(a,b,t):
	return (1 - t) * a + t * b

func _on_player_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body==$".":
		return

	body.DealDamage(1)
	

	


func _on_light_checker_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	Disappear()
	pass # Replace with function body.


func _on_ore_checker_body_entered(body: Node2D) -> void:
	
	if body.get_script()==object_ore:
		var ore:object_ore=body
		if ore.oreType.ID==11:
			ore.SetStressed(true) #if the ore is the saint, tell saint to be stressed lol

	
	pass # Replace with function body.


func _on_ore_checker_body_exited(body: Node2D) -> void:
	if body.get_script()==object_ore:
		var ore:object_ore=body
		if ore.oreType.ID==11:
			ore.SetStressed(false)
	pass # Replace with function body.
