extends Node2D
@export var gooSprites:Array[Texture]
@onready var sprite=$gabbagoo
var currentProgress:int=0
var waitingForPlayerToLeave:bool=false

var dumbCounter:float=0
var playerIsInZone:bool=false
var playerIsTrulyInZone:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	if !waitingForPlayerToLeave:
		return
	
	#I do some waiting b4 checking if player is in zone cuz the player collider turns on/off when  jumping around. I hate it but eh! 
	if playerIsInZone:
		dumbCounter= min(dumbCounter+delta,0.2)
	else:
		dumbCounter= max (0,dumbCounter-delta)
		
	if dumbCounter>=0.2 and !playerIsTrulyInZone:
		playerIsTrulyInZone=true
		
	
	if dumbCounter<=0 and playerIsTrulyInZone:
		playerIsTrulyInZone=false
		UpdateSprite()

func UpdateGooProgress(progressToHatching:float,setGooSpriteInstantly:bool=false):
	
	if !GlobalVariables.CursedMode:
		hide()
	else:
		show()
	
	var _valueToSet=roundi((gooSprites.size()-1)*progressToHatching)
	
	waitingForPlayerToLeave=true
	currentProgress=_valueToSet
	
	if setGooSpriteInstantly:
		UpdateSprite()
	
func UpdateSprite():
	if waitingForPlayerToLeave:
		sprite.texture=gooSprites[currentProgress]
		waitingForPlayerToLeave=false
	
	
func _on_player_checker_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	playerIsInZone=false

	pass # Replace with function body.


func _on_player_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	playerIsInZone=true
	pass # Replace with function body.
