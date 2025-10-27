extends Node2D

@onready var StatsParent=$STATS
@onready var statsMessage=$STATS/stats
@onready var SebsMessage=$"Sebs message"
@onready var choiceMessage=$choice
@onready var white=$white_background

enum states{inactive,info,seb,choice}
var state:states=states.inactive
signal textFinishedShowing()
signal statsFinished(bool)
@onready var text_header= $STATS/headr

var textshown:int=0

var typewriteTotalCharacterCount:int=0
@export var typewriteCharsPerSecond:float=8
var typewriteTimer:float=0
var soundTimer:float=0
var labelToTypewrite
var isTypeWriting:bool=true

var finalChoiceIsToErase:bool=true

@export var finalchoicetext_erase:String
@export var finalchoicetext_goback:String

@export var statsarray:Array[stats_shower]

@export var DebugShowStats:bool=false

func _ready() -> void:
	hide()
	StatsParent.hide()
	SebsMessage.hide()
	choiceMessage.hide()
	
	#!!!DEBUG! REMOVE ME!!!
	#lmao did not remove
	if DebugShowStats:
		HUD.SetState(HUD.menuStates.CREDITS)
		show()
		DisplaySebsMessage()

func TranslateMessages():
	SebsMessage.text=tr("credits_thanks_for_playing")
	choiceMessage.text=tr(finalchoicetext_erase)
	text_header.text=tr("credits_stats_header")

func FadeFromWhite():
	white.show()
	var alpha=1
	while alpha>0:
		
		white.self_modulate.a=alpha
		await get_tree().create_timer(0.005).timeout
		alpha-=0.005
	white.hide()

func DisplayStats():
	
	hidestuff()
	state=states.info
	StatsParent.show()
	await get_tree().create_timer(0.5).timeout
	
	var text_statinfo:String
	var text_statresult
	text_statinfo=tr("credits_stats_hatchtime")
	text_statresult="[color=orange]"+ str(GlobalVariables.currentDay)+"[/color]"+"[p][/p]"
	
	#unlock achievement for finishing within 7 days
	if 	GlobalVariables.currentDay <= SteamHandler.stat_ach_days_fastest:
		SteamHandler.TryUnlockAchievement("ach_days_fastest")
	
	statsarray[0].DisplayStat(text_statinfo,text_statresult)
	await statsarray[0].displayedStat
	
	text_statinfo=tr("credits_stats_timetaken")
	text_statresult=HUD.SpeedrunTimer.GetTimerString()

	statsarray[1].DisplayStat(text_statinfo,text_statresult)
	await statsarray[1].displayedStat

	text_statinfo=tr("credits_stats_ores")
	text_statresult=str(GlobalVariables.oresFound)+" / "+str(GlobalVariables.totalOres)

	var oresLeft:int= GlobalVariables.totalOres-GlobalVariables.oresFound
	if oresLeft<=0:
		SteamHandler.TryUnlockAchievement("ach_all_ores")

	statsarray[2].DisplayStat(text_statinfo,text_statresult)
	await statsarray[2].displayedStat

	text_statinfo=tr("credits_stats_kills")
	text_statresult=str(SteamHandler.count_enemyDeaths)
	var kills=SteamHandler.count_enemyDeaths
	
	if SteamHandler.count_enemyDeaths<=SteamHandler.stat_ach_pacifist:
		SteamHandler.TryUnlockAchievement("ach_pacifist")
		
	statsarray[3].DisplayStat(text_statinfo,text_statresult)
	await statsarray[3].displayedStat
	
	statsarray[4].DisplayStat("[center][wave][rainbow]"+tr("credits_stats_continue"),"")	
	
#	TypewriteText(statsMessage)
	
func hidestuff():
	SebsMessage.hide()
	StatsParent.hide()
	choiceMessage.hide()

func DisplaySebsMessage():
	TranslateMessages()
	hidestuff()
	show()
	FadeFromWhite()
	await get_tree().create_timer(2).timeout
	state=states.seb
	StatsParent.hide()
	SebsMessage.show()
	TypewriteText(SebsMessage)
	
	#give achievement here since all game content is over
	SteamHandler.TryUnlockAchievement("ach_finish")

func DisplayFinalChoice():
	hidestuff()
	state=states.choice
	SebsMessage.hide()
	choiceMessage.show()
	TypewriteText(choiceMessage)
	pass

func _process(delta: float) -> void:
	
	
	if Input.is_action_just_pressed("debug_tab"):
		DisplaySebsMessage()
	
	if Input.is_action_just_pressed("jump"):
		if !isTypeWriting:
			if state==states.info:
				DisplayFinalChoice()
			elif state==states.seb:
				DisplayStats()
			elif state==states.choice:
				statsFinished.emit(finalChoiceIsToErase)
	
	if state==states.choice:
		if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
			finalChoiceIsToErase=!finalChoiceIsToErase
			UpdateFinalChoiceText()
			
			if finalChoiceIsToErase:
				SoundManager.PlaySoundAtLocation($bg.global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_BECOME_HEAVY)
			else:
				SoundManager.PlaySoundAtLocation($bg.global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_WAKEUP)

			
			
			

	if isTypeWriting and labelToTypewrite!=null:
		ContinueTypewrite(delta)

func UpdateFinalChoiceText():
	
	if finalChoiceIsToErase:
		choiceMessage.text=tr(finalchoicetext_erase)
	else:
		choiceMessage.text=tr(finalchoicetext_goback)
	
	pass


var typewriteTotalTime:float
func TypewriteText(label:RichTextLabel):
	
	#todo: Change text wiritng to be a percentage instead, let text delay be dictated by character number. 
	labelToTypewrite=label
	typewriteTotalTime= labelToTypewrite.get_total_character_count()/typewriteCharsPerSecond
	isTypeWriting=true
	typewriteTimer=0
	
	
	
	pass 

var soundGoal:float=0.01
func ContinueTypewrite(delta:float):
	
	typewriteTimer+=delta
	soundTimer+=delta
	var progress=typewriteTimer/typewriteTotalTime
	
	labelToTypewrite.visible_ratio=progress
	
	
	if soundTimer>soundGoal:
		soundTimer=0
		soundGoal=randf_range(0.02,0.08)
		SoundManager.PlaySoundAtLocation($bg.global_position,abstract_SoundEffectSetting.SoundEffectEnum.TYPEWRITER_CLICK)
	
	if typewriteTimer>=typewriteTotalTime:
		textFinishedShowing.emit()
		isTypeWriting=false
	
func ConstructStatsString()->String:
	var text:String
	text+=tr("credits_stats_hatchtime")
	text+="[color=orange]"+ str(GlobalVariables.currentDay)+"[/color]"+"[p][/p]"
	text+=tr("credits_stats_timetaken")+HUD.SpeedrunTimer.GetTimerString()+"[p][/p]"
	text+=tr("credits_stats_ores")+str(GlobalVariables.oresFound)+" / "+str(GlobalVariables.totalOres)+"[p][/p]"
		
	text+="[center][wave][rainbow]"+tr("credits_stats_continue")
	
	
	return text
	
	
