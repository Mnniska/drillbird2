extends Node2D
@onready var button=$Button_Continue
var active:bool=false
var home
var camera 
@export var cameraOffset:int=-60



func Setup():
	home = GlobalVariables.MainSceneReferenceConnector.ref_home
	camera = GlobalVariables.MainSceneReferenceConnector.ref_camera
	
	if home == null or camera==null:
		push_error("Could not connect camera or home reference using mainscenerefconnector in UI_DEATH script")
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalVariables.SetupComplete.connect(Setup)
	hide()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if active:
		if Input.is_action_just_pressed("jump"):
			
			CloseUI()
			#respawn at HUB. Who handles this?
			pass
	
	pass

func CloseUI():
	hide()
	active=false
	
	home.Respawn()
	

func ShowUI():
	#await get_tree().create_timer(1).timeout
	camera.StartNewLerp(camera.position+Vector2(0,cameraOffset),0.5)
	await get_tree().create_timer(1.5).timeout
	active=true
	button.SetSelected(true)
	show()
	pass
