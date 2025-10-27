extends Node
class_name flying_credits_manager 

@onready var flyer:flying_child=$FlyingChild
@onready var credits=$Credits
@onready var valueSpawner=$ValueSpawner

@onready var backgroundBase:Sprite2D=$BG_base
@onready var backgroundStars:Sprite2D=$BG_Stars
@onready var backgroundPlanets:Sprite2D=$BG_planets
@onready var backgroundClouds:Sprite2D=$BG_clouds
@onready var backgroundCloudsCloser:Sprite2D=$BG_clouds2

@onready var text_growth=$energyMeter/text_growth

@export var BaseSpeed:float=50

@export var debugSkipCredits:bool=false

var hasEvolved:bool=false
@onready var music = $music
var musicTargetVolume:float=1
var musicVolume:float=1
var musicMaxVolume:float=0
var musicMinVolume:float=-80

var cloudsVisible:bool=true
var cloudsVisibleLerper:float=0
var isTransitioningToMainAgain:bool=false

func _process(delta: float) -> void:
			

	if musicVolume!=musicTargetVolume:
		musicVolume= lerpf(musicVolume,musicTargetVolume,delta)
		var vol=lerpf(musicMinVolume,musicMaxVolume,musicVolume)
		music.volume_db=vol
		
func _ready() -> void:
	
	credits.TranslateCredits()
	text_growth.text=tr("credits_growth")
	HUD.SetState(HUD.menuStates.CREDITS)
	music.finished.connect(music.play)
	
	
	await get_tree().create_timer(1).timeout
	flyer.initiateJump(1)

	if debugSkipCredits:
		valueSpawner.active=true
		SetCloudsVisible(false)
	else:
		SetCloudsVisible(true)
		credits.active=true
		credits.signal_credits_finished.connect(CreditsFinished)
		

func CreditsFinished():
	valueSpawner.active=true
	SetCloudsVisible(false)

func SetCloudsVisible(visible:bool):
	backgroundClouds.showParallax=visible
	backgroundCloudsCloser.showParallax=visible


func _on_player_detector_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	flyer.initiateJump(randf_range(0.3,0.6))
	pass # Replace with function body.


func _on_flying_child_has_evolved() -> void:
	valueSpawner.active=false
	TriggerFinalZinger()

func MusicRepeat():
	music.play()

func TriggerFinalZinger():
	
	
	hasEvolved=true
	SoundManager.PlaySoundAtLocation($Camera2D.global_position,abstract_SoundEffectSetting.SoundEffectEnum.DRILLBIRD_OUTRO_ZINGER)
	
	await get_tree().create_timer(13).timeout
	musicTargetVolume=0.85
	


func _on_flying_child_has_evolved_off_screen() -> void:
	if isTransitioningToMainAgain:
		return
	isTransitioningToMainAgain=true
	var anim:AnimationPlayer=$AnimationPlayer
	anim.play("fall")
	await get_tree().create_timer(7).timeout
	ShowStats()

func ShowStats():
	var stats = $"Final stats"
	stats.DisplaySebsMessage()
	stats.statsFinished.connect(StatsFinished)
	
func StatsFinished(eraseData:bool):
	
	HUD.SetSceneState(HUD.sceneStates.MAIN,false,eraseData)
	
func _on_flying_child_can_evolve_update(yes: bool) -> void:
	if yes:
		pass
		musicTargetVolume=0
	else:
		pass
		musicTargetVolume=1
