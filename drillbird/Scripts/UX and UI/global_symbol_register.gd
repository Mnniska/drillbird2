extends Node
class_name global_symbol_register

enum languages{en,sv,ja,zh,ru}
var currentLanguage:languages

var usingGamepad:bool=true
@export var symbols:Array[abstract_symbol_info]

var keyboard_effect_begin="[wave][color=orange][font_size=32]"
var keyboard_effect_end="[/font_size][/color][/wave]"


func _ready() -> void:
	pass
	

func GetStringDecoded(_str:String):
	var symbolName:String=""
	var text=""
	#parses through [symbols] and replaces them wqith appropiate image links
	for _char in _str:
		
		if _char =='(' or symbolName.length()>0:
			symbolName+=_char
			if _char==')':
				text+="[img]"+GetSymbolFromString(symbolName)+"[/img]"

				symbolName=""
		else:
			text+=_char
	return text

func GetSymbolFromString(_str:String)->String:
	for symbol in symbols:
		if symbol.code==_str:
			if usingGamepad:
				return "[img]"+symbol.img_path_gamepad+"[/img]"
			else:
				var key_name =""
				#assigning your input action from Project Settings Input Map
				var prompt_action = symbol.img_path_keyboard
				if InputMap.has_action(prompt_action):
					# will depend on how many keys assigned to action
					var key_action = InputMap.action_get_events(prompt_action)[0]
					var key_string = OS.get_keycode_string(key_action.physical_keycode)
					key_name = str(key_string)
					return keyboard_effect_begin+key_name+keyboard_effect_end
	
	push_error("Could not find a matching symbol! "+str(_str)+" was asked for but I dunno what that is?")
	return ""
	

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		usingGamepad=false
	
	if event is InputEventJoypadButton:
		usingGamepad=true	
