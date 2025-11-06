extends Node
class_name global_symbol_register

enum languages{en,sv,ja,zh,ru}
var currentLanguage:languages

var usingGamepad:bool=true
@export var symbols:Array[abstract_symbol_info]
@export var currentController:int=0

var keyboard_effect_begin="[wave][color=orange]"
var keyboard_effect_end="[/color][/wave]"


func _ready() -> void:
	#Maybe this should not be here, but it's where we do input shenanigans ;) 

	pass
	

func GetStringDecoded(_str:String,useoutline:bool=false):
	var symbolName:String=""
	var text=""
	#parses through [symbols] and replaces them wqith appropiate image links
	for _char in _str:
		
		if _char =='(' or symbolName.length()>0:
			symbolName+=_char
			if _char==')':
				text+=GetSymbolFromString(symbolName,useoutline)

				symbolName=""
		else:
			text+=_char
	return text

func GetSymbolFromString(_str:String,useoutline:bool=false)->String:
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
					
					var outline_begin=""
					var outline_end=""
					
					if useoutline:
						outline_begin="[outline_size={2}]"
						outline_end="[/outline_size]"
					
					
					return outline_begin+keyboard_effect_begin+key_name+keyboard_effect_end+outline_end
	
	push_error("Could not find a matching symbol! "+str(_str)+" was asked for but I dunno what that is?")
	return ""
	

func _input(event: InputEvent) -> void:
	
	if event is InputEventJoypadButton:
		if currentController!=event.device:
			currentController=event.device
	
	if event is InputEventKey:
		if usingGamepad:
			#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			usingGamepad=false
	
	if event is InputEventJoypadButton or InputEventJoypadMotion:
		if !usingGamepad:
			#Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)	
			usingGamepad=true	
		
