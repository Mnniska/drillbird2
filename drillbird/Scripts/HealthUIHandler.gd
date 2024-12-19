extends Node2D

var HealthArray:Array[Node2D] #I'd love for this to specify the heart script. Make sure to loop up a tutorial over christmas :) 
var HealthScene
@export var HealthUpgrades:abstract_purchasable
var HeartScene = preload("res://Scenes/HeartScene.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HealthSetup()
	pass # Replace with function body.

func _process(delta:float)->void: 
	
	#debug test
	if Input.is_action_just_pressed("removeLight"):
		TakeDamage(1)
	if Input.is_action_just_pressed("addLight"):
		RefillHealth()
	
func HealthSetup():
	
	var HeartAmount:int = HealthUpgrades.items[GlobalVariables.upgradeLevel_health].power
	var offset:int=11
	
	for n in HeartAmount:
		var heartInstance=HeartScene.instantiate()
		heartInstance.transform.origin+=Vector2(offset*n,0)
		add_child(heartInstance)
		HealthArray.append(heartInstance)
		pass
	
	RefillHealth()
	pass
	
func RefillHealth():
	for n in HealthArray:
		n.RefillHeart()

func TakeDamage(amount:int):

	var DamageCounter:int=0
	var index:int=0
	var lastHeart:bool=false
	
	for n in HealthArray:
		var c:int=HealthArray.size()-(index+1)
		
		if HealthArray[c].TakeDamage(): #Will return false if selected heart is empty
			
			lastHeart=index==HealthArray.size()-2
			if lastHeart:
				n.SetIsLastHeart()
					
			DamageCounter+=1
			if DamageCounter>=amount: #continue removing health until specified amount has been taken
				break
		index+=1
	
	var survived:bool=false
	for n in HealthArray:
		if n.full:
			survived=true
	
	if !survived:
		print_debug("Player has DIED!")
		pass
		#Do death stuff!

	pass
