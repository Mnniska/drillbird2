extends Node2D

var HealthArray:Array[heart_script] #I'd love for this to specify the heart script. Make sure to loop up a tutorial over christmas :) 
var HealthScene
@export var HealthUpgrades:abstract_purchasable
var HeartScene = preload("res://Scenes/UI/HeartScene.tscn")
@onready var UI_DeathPopup=$"../../UI_Death"
@onready var lightManager=$"../LightHandler"
var isOnLightHeart:bool=false

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HealthSetup()
	GlobalVariables.upgradeChange_Health.connect(upgradeChangeHealth)

	pass # Replace with function body.

func _process(delta:float)->void: 
	pass

func upgradeChangeHealth():
	UpgradeHealth()
	pass

func UpgradeHealth():
	for n in HealthArray:
		n.queue_free()

	HealthArray.clear()
	HealthSetup()
	pass

func HealthSetup():
	if GlobalVariables.upgradeLevel_health >HealthUpgrades.items.size()-1:
		GlobalVariables.upgradeLevel_health=HealthUpgrades.items.size()-1
		
	GlobalVariables.playerHealth=HealthUpgrades.items[GlobalVariables.upgradeLevel_health].power
	var HeartAmount:int = HealthUpgrades.items[GlobalVariables.upgradeLevel_health].power
	var offset:int=11
	
	for n in HeartAmount:
		var heartInstance=HeartScene.instantiate()
		heartInstance.transform.origin+=Vector2(offset*n,0)
		add_child(heartInstance)
		HealthArray.append(heartInstance)
		pass
	
	RefillHealth()
	print_debug("Array size: "+str(HealthArray.size()))
	pass
	
func RefillHealth():
	isOnLightHeart = false
	for n in HealthArray:
		n.RefillHeart()
	GlobalVariables.playerHealth=HealthUpgrades.items[GlobalVariables.upgradeLevel_health].power

func TakeDamage(amount:int):

	GlobalVariables.playerHealth-=amount #reduce player health
	
	
	
	var DamageCounter:int=0
	var index:int=0

	for heart:heart_script in HealthArray:
		
		#Iterate thru array backwards
		var heartID:int=HealthArray.size()-index-1
		var currentHeart:heart_script = HealthArray[heartID]
		if currentHeart.TakeDamage():
		
			if heartID==1:
				HealthArray[0].SetIsLastHeart(isOnLightHeart)
		
			#continue removing health until specified amount has been taken
			DamageCounter+=1
			if DamageCounter>=amount: 
				break
		
		index+=1
		
	if GlobalVariables.playerHealth<=0:
		if isOnLightHeart:
			UI_DeathPopup.ShowUI()
		else:
			if lightManager.RequestRefillHealthWithLight():
				isOnLightHeart = true
				GlobalVariables.playerHealth=1
				HealthArray[0].SetIsLastHeart(isOnLightHeart)

				pass
				#give player one last health and make it yellow 
			else:
				UI_DeathPopup.ShowUI()

		
		pass
	

	
"	var survived:bool=false
	for n in HealthArray:
		if n.full:
			survived=true
	
	if !survived:
		UI_DeathPopup.ShowUI()
		pass"
	
		#Do death stuff!
