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

var statsPageBusyLol:bool=false
#added so that players can't skip stats page, which does not use the IsTypeWriting logic. bad code should clean up but I'm in a bit of a rush

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
	statsPageBusyLol=true
	hidestuff()
	state=states.info
	StatsParent.show()
	await get_tree().create_timer(0.5).timeout
	
	var text_statinfo:String
	var text_statresult
	text_statinfo=tr("credits_stats_hatchtime")+" "
	text_statresult="[color=orange]"+ str(GlobalVariables.currentDay)+"[/color]"+"[p][/p]"
	
	statsarray[0].DisplayStat(text_statinfo,text_statresult)
	await statsarray[0].displayedStat
		#unlock achievement for finishing within 7 days
	if 	GlobalVariables.currentDay <= SteamHandler.stat_ach_days_fastest:
		SteamHandler.TryUnlockAchievement("ach_days_fastest")
	
	text_statinfo=tr("credits_stats_timetaken")+" "
	text_statresult=HUD.SpeedrunTimer.GetTimerString()

	statsarray[1].DisplayStat(text_statinfo,text_statresult)
	await statsarray[1].displayedStat
	
		
	var percent:float= float(GlobalVariables.oresFound)/float(GlobalVariables.totalOres)
	
	var percentInt:int= int(percent*100)
	text_statinfo=tr("credits_stats_ores")+" "
	text_statresult=str(percentInt)+" % "
	


	statsarray[2].DisplayStat(text_statinfo,text_statresult)
	await statsarray[2].displayedStat
	if percentInt>=90:
		SteamHandler.TryUnlockAchievement("ach_all_ores")		


	text_statinfo=tr("credits_stats_kills")+" "
	text_statresult=str(SteamHandler.count_enemyDeaths)
	

		
	statsarray[3].DisplayStat(text_statinfo,text_statresult)
	await statsarray[3].displayedStat
	if SteamHandler.count_enemyDeaths<=SteamHandler.stat_ach_pacifist:
		SteamHandler.TryUnlockAchievement("ach_pacifist")
	
	statsarray[4].DisplayStat("[center][wave][rainbow]"+tr("credits_stats_continue"),"")	
	
	statsPageBusyLol=false
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
	
	if Input.is_action_just_pressed("jump"):
		
		#Display next set of stats 
		if !isTypeWriting and !statsPageBusyLol:
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
	var percent:float=GlobalVariables.oresFound/GlobalVariables.totalOres*100
	text+=tr("credits_stats_ores")+str(percent)+" % "+"[p][/p]"
	

		
	text+="[center][wave][rainbow]"+tr("credits_stats_continue")
	
	
	return text
	
	
