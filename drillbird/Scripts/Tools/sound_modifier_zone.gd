extends Node2D

var playerInZone:bool=false
var counter:float=0

var sleeping:bool=true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if sleeping:
		return
		
	if playerInZone and counter<=0.1:
		counter+=delta
	else:
		counter-=delta
	
	if counter>0.1:
		SetActive(true)
		
	if counter<0:
		SetActive(false)
		sleeping=true

func SetActive(active:bool):
	GlobalVariables.playerIsReverbing=active
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	playerInZone=true
	sleeping=false


func _on_area_2d_body_exited(body: Node2D) -> void:
	playerInZone=false
