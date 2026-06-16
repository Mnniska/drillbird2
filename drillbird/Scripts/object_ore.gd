extends RigidBody2D
class_name object_ore
@onready var anim: AnimatedSprite2D =$Animation
@export var ObjectInfo:abstract_collidable
@export var oreType:abstract_ore
@onready var oreAnim:AnimatedSprite2D=$oreVisual
var cooldown:bool=false
var cooldownTime:float=2
var MoveTarget:Vector2
var isBeingSuckedUp:bool=false
var isStatic:bool=false
signal finishedEscapeAnimation

var isEscaping:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func GetCollType():
	
	return ObjectInfo

func GetOre():
	if oreType!=null:
		return oreType
	else:
		push_warning("Tried to access a null oretype")

func CalculateOreSparkle():
	
	
	var selfValue:float= float(oreType.value)
	
	SetSparkly(selfValue>=GlobalVariables.currentImpressedValue)
	
func SetSparkly(sparkly:bool):
	if sparkly:
		$Sparkles.show()
	else:
		$Sparkles.hide()

func SetOreType(ore:abstract_ore,_cooldown:bool,placedByGhost:bool=false):
	if(oreType==null):
		
		oreType=ore
		
		oreAnim.animation=ore.name
		oreAnim.play()
		
		cooldown=_cooldown
		
		if cooldown:
			CooldownAnimation()
		
		if placedByGhost:
			gravity_scale=0
			
		CalculateOreSparkle()

	pass

func CooldownAnimation():
	
	var a=1.0
	var b = 0.5
	var time = 0.1
	var timeKeeper=0
	
	while cooldown:
		oreAnim.self_modulate=Color(1,1,1,b)
		await get_tree().create_timer(time).timeout
		oreAnim.self_modulate=Color(1,1,1,a)
		await get_tree().create_timer(time).timeout
		
		timeKeeper+=time*2
		if timeKeeper>cooldownTime:
			cooldown=false
	
func DealDamage(_amount:int,spawnCorpse:bool=false):
	queue_free()
	# TODO: Add sick destroy effect
	pass
	
	
func MoveTowardsHome(pos:Vector2):
	MoveTarget=pos
	isBeingSuckedUp=true
	gravity_scale=0.5
	
	while linear_velocity.x>0:
		linear_velocity.x=move_toward(linear_velocity.x,0,0.2)
		linear_velocity.y=move_toward(linear_velocity.y,0,1)
		await get_tree().create_timer(randf_range(0.1,0.2)).timeout

		pass
	
	while isBeingSuckedUp:
		var pointVector = MoveTarget-self.position
		pointVector=pointVector.normalized()
		
		var force=200
		apply_central_impulse(Vector2(pointVector.x*force,0))
		
		await get_tree().create_timer(randf_range(0.2,0.5)).timeout
	
	pass

func _on_animation_animation_finished() -> void:
	anim.animation="idle"
	pass # Replace with function body.

func SetStressed(stressed:bool):
	if oreType.ID!=11:
		return
	
	if stressed:
		anim.animation="saint_stressed"
	else:
		anim.animation="SaintSoul"
	
func PlayDemonEscapeAnim():

	isEscaping=true
	#anim.play("saint_escape")
	await get_tree().create_timer(0.6).timeout
	finishedEscapeAnimation.emit()
	isEscaping=false

func _on_body_entered(_body: Node) -> void:
	SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.ORE_LAND)
	
	pass # Replace with function body.
