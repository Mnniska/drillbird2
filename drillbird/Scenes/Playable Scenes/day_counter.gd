extends RichTextLabel
@onready var txt:RichTextLabel = $"."

var txt_dayeffect_start:String="[shake rate=20.0 level=5 connected=1]"
var txt_dayeffect_end:String="[/shake]"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	txt.text="[center]"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func Activate(day:int):
	
	txt.text="[center]"+tr("popup_gamesaved")
	
	txt.self_modulate=Color(1,1,1,1)

	var length= await DisplayText(0)
	
	var txtday:String=str(day)
	
	txt.text+= "[p][center][shake] Day:"
	
	await get_tree().create_timer(0.3).timeout
	
	txt.text="[center]"+tr("popup_gamesaved")+"[p][center][shake]"+tr("popup_gamesaved_day")+txtday
	txt.visible_characters=-1
	await get_tree().create_timer(0.4).timeout

	
	var val=1
	
	while val>0:
		await get_tree().create_timer(0.02).timeout
		val-=0.01
		txt.self_modulate=Color(1,1,1,val)

	
	pass

func DisplayText(startPlace:int):
	var visibleChars:int=startPlace

	for n in txt.text.length():
		txt.visible_characters=visibleChars
		visibleChars+=1
		await get_tree().create_timer(0.06).timeout
		
	
	return txt.text.length()
	
