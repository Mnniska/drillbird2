extends Node2D
signal CutsceneComplete(skipped:bool)

@onready var anim:AnimationPlayer=$AnimationPlayer
@onready var birdySpriteframes:AnimatedSprite2D=$birdy
@onready var skyCameraPos:Vector2=$cameraLerpPos_sky.global_position
@onready var nestCameraPos:Vector2=$cameraLerpPos_nest.global_position

@onready var fakePlayer:AnimatedSprite2D=$PlayerVisuals
var lerpTime:float=2
var lerpCounter:float=0
var isLerping:bool=false
var lerpStartPos:Vector2

var birdVibrate:bool=false
@onready var birdyPosition=$birdy.global_position

func _ready() -> void:
	hide()

func _process(delta: float) -> void:

	if isLerping:

		lerpCounter+=delta
		var progress=lerpCounter/lerpTime
		var pos:Vector2=Vector2(lerpf(lerpStartPos.x,birdyPosition.x,progress),lerpf(lerpStartPos.y,birdyPosition.y,progress))
		fakePlayer.global_position=pos
		
		if progress>=1:
			isLerping=false
			fakePlayer.hide()
		
		
	if birdVibrate:
		var vibrate=1
		birdySpriteframes.global_position = birdyPosition + Vector2(randf_range(-vibrate,vibrate),0)

func VibrateBird():
	birdVibrate=true

var cameraInSky:bool=false
func CameraPanToSky():
	cameraInSky=true
	GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(skyCameraPos,2)
	await get_tree().create_timer(4).timeout
	cameraInSky=false
	if !cutsceneSkipped:
		GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(nestCameraPos,2)
	
	#make egg transition to natural rest pos here and save game

	pass



func TransitionToCutscene(playerpos:Vector2,_transitionTime:float):
	
	lerpStartPos=playerpos
	fakePlayer.global_position=lerpStartPos
	isLerping=true
	fakePlayer.show()
	
	pass
	
var cutsceneSkipped:bool=false
func SkipCutscene():
	
	lerpCounter=lerpTime
	cutsceneSkipped=true
	
	if cameraInSky:
		GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(nestCameraPos,1)
	AnimFinished(true)
	GlobalVariables.PlayerPressedSkipButton.disconnect(SkipCutscene) 
	
	
	pass
func Play():
	
	if GlobalVariables.hasSeenEggLaying:
		GlobalVariables.PlayerPressedSkipButton.connect(SkipCutscene) #TODO: only show skip button if player has seen cutscene once
		HUD.SetSkipButtonEnabled(true)
	
	birdVibrate=false
	var transitionTime:float=2
	TransitionToCutscene(GlobalVariables.PlayerController.global_position,transitionTime)
	GlobalVariables.MainSceneReferenceConnector.camera.StartNewLerp(nestCameraPos,transitionTime/1.5)
	
	show()
	anim.play("wait")
	birdySpriteframes.play()

	await get_tree().create_timer(transitionTime).timeout
	
	if cutsceneSkipped:
		return
		
	anim.play("play")
	SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.SCENE_NESTING)
	#anim.animation_finished.connect(AnimFinished)
	
func AnimFinished(skipped:bool=false):
	hide()
	CutsceneComplete.emit(skipped)
	GlobalVariables.PlayerPressedSkipButton.disconnect(SkipCutscene) 
	GlobalVariables.hasSeenEggLaying=true
	HUD.SetSkipButtonEnabled(false)
	pass
