extends Sprite2D
class_name single_parallax

@export var parallaxStartPos:Vector2
@export var parallaxEndPos:Vector2
@export var globalPlayerStartPos:Vector2
@export var globalPlayerEndPos:Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func UpdateParallax(_playerpos:Vector2):
	
	var pos:Vector2
	
	if _playerpos.x<globalPlayerStartPos.x:
		pos.x=parallaxStartPos.x

	if _playerpos.x>globalPlayerStartPos.x:
		pos.x=parallaxEndPos.x
	
	if _playerpos.x>globalPlayerStartPos.x and _playerpos.x < globalPlayerEndPos.x:
		#player is within range of parallax reacting
		
		var progress = abs((_playerpos.x-globalPlayerStartPos.x)/(globalPlayerEndPos.x-globalPlayerStartPos.x))
		pos.x= parallaxStartPos.x + progress * (parallaxStartPos.x-parallaxEndPos.x)
		
		pass

	if _playerpos.y<globalPlayerStartPos.y:
		pos.x=parallaxStartPos.y

	if _playerpos.y>globalPlayerStartPos.y:
		pos.x=parallaxEndPos.y
	
	if _playerpos.y < globalPlayerStartPos.y and _playerpos.y > globalPlayerEndPos.y:
		#player is within range of parallax reacting
		var progress = abs((_playerpos.y-globalPlayerStartPos.y)/(globalPlayerEndPos.y-globalPlayerStartPos.y))
		pos.y= parallaxStartPos.y + progress * (parallaxStartPos.y-parallaxEndPos.y)
		
		
	position=pos
	
	
	pass
