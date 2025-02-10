extends Node2D
class_name sell_location_script

var available:bool =true

func BeginSellingOre(timeToSell:float):
	available=false
	await get_tree().create_timer(timeToSell).timeout
	available=true
