extends TileMapLayer

@export var startPos:float
@export var endPos:float

@export var playerStartPos:float
@export var playerEndPos:float

var player:Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(GetPlayer)
	
	pass # Replace with function body.

func GetPlayer():
	player=GlobalVariables.MainSceneReferenceConnector.player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if player!=null:
		UpdateParallax(player)
	pass


func UpdateParallax(_player:Node2D):
	
	var posX=0
	var playerpos=_player.global_position.x
	if playerpos<playerStartPos:
		posX=startPos
	elif playerpos>playerEndPos:
		posX=endPos
	else:
		var progress = abs(playerpos-playerStartPos)/abs(playerEndPos-playerStartPos)
		posX=startPos+progress*(startPos-endPos)
	
	position.x=posX
