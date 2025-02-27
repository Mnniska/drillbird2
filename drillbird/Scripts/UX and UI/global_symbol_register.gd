extends Node
class_name global_symbol_register

var usingGamepad:bool=true
@export var symbols:Array[abstract_symbol_info]

func GetStringDecoded(_str:String):
	var symbolName:String=""
	var text=""
	#parses through [symbols] and replaces them wqith appropiate image links
	for _char in _str:
		
		if _char =='[' or symbolName.length()>0:
			symbolName+=_char
			if _char==']':
				text+="[img]"+GetSymbolFromString(symbolName)+"[/img]"

				symbolName=""
		else:
			text+=_char
	return text

func GetSymbolFromString(_str:String)->String:
	for symbol in symbols:
		if symbol.code==_str:
			if usingGamepad:
				return symbol.img_path_gamepad
			else:
				return symbol.img_path_keyboard
	
	push_error("Could not find a matching symbol! "+str(_str)+" was asked for but I dunno what that is?")
	return ""
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		usingGamepad=false
	
	if event is InputEventJoypadButton:
		usingGamepad=true	
