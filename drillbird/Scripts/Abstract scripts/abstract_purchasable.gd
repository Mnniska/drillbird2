extends Resource
class_name abstract_purchasable
@export var onlyAButton:bool=false
@export var type:GlobalVariables.typeEnum
@export var icon:Texture2D
@export var itemNameID:String ="default"
@export var itemDescriptionID ="default description"

@export var items:Array[abstract_item_upgrade]
