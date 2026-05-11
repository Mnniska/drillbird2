extends Node2D
@onready var cloudcollider=$CloudCollider
@onready var text=$text

var amountOfClouds:int=0
var shakeCounter:float=0
var shouldUpdate:bool=false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if !shouldUpdate:
		return
	
	shakeCounter+=delta
	
	if shakeCounter<0.2:
		text.text="[center][shake]"+str(amountOfClouds)
	else:
		text.text="[center]"+str(amountOfClouds)
		shouldUpdate=false
	
	pass



func _on_cloud_collider_body_entered(body: Node2D) -> void:
	UpdateCounter()
	
	pass # Replace with function body.


func _on_cloud_collider_body_exited(body: Node2D) -> void:
	UpdateCounter()
	pass # Replace with function body.

func UpdateCounter():
	var n=0
	for collisions in cloudcollider.get_overlapping_bodies():
		n+=1
	
	shouldUpdate=true
	amountOfClouds=n
	shakeCounter=0
	text.text="[center][shake]"+str(n)
	

	
