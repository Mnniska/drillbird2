extends Node2D
class_name background_handler

@export var background_normal:Texture
@export var background_cursed_back:Texture
@export var background_cursed_front:Texture

@onready var background_back:Sprite2D=$Sprite_HUBBackground_back
@onready var background_front:Sprite2D=$Sprite_HUBBackground_front
@export var setupForCursedModeTrailer:bool=false
@export var timeToTween:float=2
var tweenCounter:float=0
var showFront:bool=false

var objectsRequestingIntenseBackground:int=0
#if at least 1 object requests an intense background, make it so

func _ready() -> void:
	await GlobalVariables.SetupComplete
	SetCursedMode(GlobalVariables.CursedMode)
	SetShowBackgroundFrontLayer(false)
	
	
	var children:Array[Node] = $intensifiers.get_children()
	
	if !setupForCursedModeTrailer:
		for collider in children:
			var coll:Area2D=collider
			coll.body_entered.connect(PlayerEnteredACollider)
			coll.body_exited.connect(PlayerExitedACollider)
	
func LightRequestsIntensity(intense:bool):
	if setupForCursedModeTrailer:
		return
	if intense:
		objectsRequestingIntenseBackground+=1
	else:
		objectsRequestingIntenseBackground-=1
	
	UpdateAfterColliderChange()
	
func PlayerEnteredACollider(_body: Node2D):
	objectsRequestingIntenseBackground+=1
	UpdateAfterColliderChange()
	pass

func PlayerExitedACollider(_body: Node2D):
	objectsRequestingIntenseBackground-=1
	UpdateAfterColliderChange()
	pass
	

func SetCursedMode(cursed:bool):
	if !cursed:
		background_back.texture=background_normal
		background_front.texture=background_normal
	else:
		background_back.texture=background_cursed_back
		background_front.texture=background_cursed_front

var isUsingNormalBG:bool=true
func SwitchToCursedModeBackground():
	background_front.show()
	
	isUsingNormalBG=!isUsingNormalBG
		
	
	if isUsingNormalBG:
		background_front.texture=background_normal
	else:
		background_front.texture=background_cursed_front


func UpdateAfterColliderChange():
	if objectsRequestingIntenseBackground>0:
		SetShowBackgroundFrontLayer(true)
	else:
		SetShowBackgroundFrontLayer(false)

func SetShowBackgroundFrontLayer(_front_active:bool):
	
	showFront=_front_active

func _process(delta: float) -> void:
	if setupForCursedModeTrailer:
		return
		
	if showFront and tweenCounter>timeToTween:
		return
	if !showFront and tweenCounter<=0:
		return
	
	if showFront:
		tweenCounter=min(tweenCounter+delta,timeToTween)
		var progress=tweenCounter/timeToTween
		background_front.modulate.a=progress*1
	else:
		tweenCounter=max(tweenCounter-delta,0)
		var progress=tweenCounter/timeToTween
		background_front.modulate.a=progress*1
