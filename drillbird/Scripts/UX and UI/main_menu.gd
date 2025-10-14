extends Control

signal NewGame
signal press_options
signal press_quit

@export var options:Array[abstract_debugMenuOption]
@onready var menuText=$mainMenuText
var textbegin="[center]"
var textend="[/center]"

var selectionEffectBegin="[color=orange][wave amp=50.0 freq=5.0 connected=1]"
var selectionEffectEnd="[/wave][/color]"

var selection:int=0

var active:bool=false
var cooldown:float=0

var fadeValue:float=1
var shouldBeVisible:bool=true
var timeToFade:float=1
var fadeCounter:float=2

# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	

	UpdateMenuOpacity(delta)

	if !active:
		cooldown=0
		return
	else:
		cooldown+=delta
		if cooldown<0.4:
			return
		
	if Input.is_action_just_pressed("up"):
		selection-=1
		PlayMenuSound(menu_sounds.up)
		if selection<0:
			selection=options.size()-1
		GenerateMainMenu()
	if Input.is_action_just_pressed("down"):
		selection+=1
		PlayMenuSound(menu_sounds.down)
		if selection>options.size()-1:
			selection=0
		GenerateMainMenu()
		
	
	if Input.is_action_just_pressed("jump"):
		PressButton()
		PlayMenuSound(menu_sounds.select)
	

enum menu_sounds{up,down,select,back,toggle_yes,toggle_no}

func PlayMenuSound(sound:menu_sounds):
	
	match sound:
		menu_sounds.up:
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_UP)
		menu_sounds.down:
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_DOWN)
		menu_sounds.select:
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_PURCHASE_YES)
		menu_sounds.back:
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.HOME_MENU_PURCHASE_NO)
		menu_sounds.toggle_yes:
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_WAKEUP)
		menu_sounds.toggle_no:
			SoundManager.PlaySoundGlobal(abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_BECOME_HEAVY)
	pass

func UpdateMenuOpacity(delta:float):
	if shouldBeVisible and fadeValue<1:
		fadeCounter=min(timeToFade,fadeCounter+delta)
		fadeValue=fadeCounter/timeToFade
		UpdateMenuFade(fadeValue)
		
	if !shouldBeVisible and fadeValue>0:
		fadeCounter=max(0,fadeCounter-delta)
		fadeValue=fadeCounter/timeToFade
		UpdateMenuFade(fadeValue)

func SetMenuMusicActive(active:bool=true):
	
	var music:AudioStreamPlayer2D = $MenuMusic
	
	if active:
		if !music.playing:
			music.volume_db=0
			music.play()
			
	else:
		FadeOutMusic()

func FadeOutMusic():
	var music:AudioStreamPlayer2D = $MenuMusic
	while music.volume_db>-70:
		music.volume_db-=1
		await get_tree().create_timer(0.035).timeout
	
	music.stop()
	
	pass

func GenerateMainMenu():
	
	active=true
	
	if !GlobalVariables.hasSeenIntroCutscene:
		options[0].name="menu_new_game"
		SetMenuMusicActive(true)
	else:
		options[0].name="menu_continue"

	
	var textstring=textbegin
	
	var index:int=0
	for option in options:
		if selection==index:
			textstring+=selectionEffectBegin
			
		textstring+=tr(option.name)+"\n"
		
		if selection==index:
			textstring+=selectionEffectEnd
		index+=1
	
	textstring+=textend
	menuText.text=textstring

func Deactivate():
	active=false
	hide()
	
func PressButton():
	if !active:
		return
	match options[selection].name:
		"menu_new_game":
			NewGame.emit()
			SetMenuMusicActive(false)
		"menu_continue":
			NewGame.emit()
		"menu_options":
			press_options.emit()
		"menu_quit":
			press_quit.emit()
	

func SetShouldBeVisible(visible:bool):
	shouldBeVisible=visible
	
	if visible:
		menuText.show()
		active=true
	
	else:
		menuText.hide()
		active=false
	

func UpdateMenuFade(progress:float):
	
	var color=Color(Color.WHITE,progress)
	self.modulate=color
	
		

	
