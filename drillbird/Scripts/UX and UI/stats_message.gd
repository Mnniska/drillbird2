extends RichTextLabel
class_name stats_shower
@onready var textlabel=$"."

signal displayedStat

func _ready() -> void:
	textlabel.text=""

func DisplayStat(text_to_show:String,stat:String,displayInstantly:bool=false):
	
	if displayInstantly:
		textlabel.text=text_to_show+stat
		visible_characters=-1
		return
	
	var charactersShown:int=0
	
	textlabel.text=text_to_show
	var totalCharacters=textlabel.get_parsed_text().length()
	
	while charactersShown<totalCharacters:
		charactersShown+=1
		textlabel.visible_characters=charactersShown
		
		await get_tree().create_timer(0.05).timeout
		SoundManager.PlaySoundAtLocation(position,abstract_SoundEffectSetting.SoundEffectEnum.TYPEWRITER_CLICK)


	if stat=="":
		displayedStat.emit()
		return

	await get_tree().create_timer(0.3).timeout
	
	textlabel.visible_characters=-1
	textlabel.text=text_to_show+stat
	#placeholder sound
	SoundManager.PlaySoundAtLocation(position,abstract_SoundEffectSetting.SoundEffectEnum.FALLBLOCK_LAND)
	
	await get_tree().create_timer(0.5).timeout
	displayedStat.emit()
	
	pass
