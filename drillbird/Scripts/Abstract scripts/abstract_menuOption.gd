extends Resource
class_name abstract_menu_option

@export var optionName:String = "Default"
@export var subMenu:Array[abstract_menu_option]
@export var goesDeeper:bool=false
@export var isToggle:bool=false
@export var isSlider:bool=false
@export var SoundSample:AudioStreamWAV
