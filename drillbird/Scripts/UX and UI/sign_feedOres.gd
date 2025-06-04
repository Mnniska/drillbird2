extends Node2D
var active:bool=false
@export var textToShow:String="game_egg_feed"

@onready var text_icon=$HBoxContainer/iconHolder/text_icon
@onready var text_feedEgg=$HBoxContainer/text_feedEgg

func SetActive(_active:bool):
	

	
	active=_active
	
	if active and GlobalVariables.displayPopups:
		text_icon.text="[center]"+GlobalSymbolRegister.GetStringDecoded("(inventory)")
		text_feedEgg.text=tr(textToShow)

		show()
	else:
		hide()

	
	
