extends RichTextLabel
@onready var txt:RichTextLabel = $"."

var txt_dayeffect_start:String="[shake rate=20.0 level=5 connected=1]"
var txt_dayeffect_end:String="[/shake]"
var txt_gameSaved:String="Game Saved! "

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	txt.text="[center]"
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	pass


func Activate(day:int):
	
	txt.text="[center]"+txt_gameSaved
	txt.self_modulate=Color(1,1,1,1)

	var length= await DisplayText(0)
	
	var txtday:String=str(day-1)
	
	txt.text+= "Day:"
	
	await DisplayText(length)
	
	txtday=txt_dayeffect_start+str(day)+txt_dayeffect_end
	txt.text=txt_gameSaved+"Day: "+txtday
	txt.visible_characters=-1
	
	
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
	
