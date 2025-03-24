extends Node2D
var active:bool=false
@export var textToShow:String="[inventory] feed ores"

func SetActive(_active:bool):
	active=_active
	
	if active and GlobalVariables.displayPopups:
		$txt.text=GlobalSymbolRegister.GetStringDecoded(textToShow)
		show()
	else:
		hide()

	
	
