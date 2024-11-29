extends CharacterBody2D

var animstate=""
enum Directions {LEFT, RIGHT, UP, DOWN}
var facingDir= Directions.RIGHT
@export var SPEED = 100.0
@export var JUMP_VELOCITY = -200.0
@onready var raycast_drill = $RayCast2D
@onready var debugLine= $DebugRaycastLine
@onready var tilemap: TileMapLayer = get_parent().get_node("TileMapLayer")


func _ready() -> void:
	Update_Animations("idle")
	debugLine.points.clear()
	debugLine.add_point(raycast_drill.position)
	debugLine.add_point((raycast_drill.target_position))
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	var newanim=animstate
	if direction:
		velocity.x = direction * SPEED
		
		if velocity.x > 0:
			facingDir=Directions.RIGHT
		elif velocity.x<0:
			facingDir=Directions.LEFT
		newanim="run"
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		newanim="idle"
		
		#if not moving left/right, handle whether char should look up/down
		
		if Input.is_action_pressed("up"):
			facingDir=Directions.UP
			newanim="idle_up"
		if Input.is_action_pressed("down"):
			facingDir=Directions.DOWN
			newanim="idle_down"
			
		if Input.is_action_pressed ("drill"):
			newanim="drill_side"
			TryDrilling()

	move_and_slide()
	Update_Animations(newanim)
	
func TryDrilling(): 
	
	var raycastTarget = Vector2i(0,0)

	match facingDir:
		Directions.LEFT:
			raycastTarget=Vector2(-15,0)			
		Directions.RIGHT:
			raycastTarget=Vector2(15,0)
		Directions.UP:
			raycastTarget=Vector2(0,-15)
		Directions.DOWN:
			raycastTarget=Vector2(0,15)
	raycast_drill.target_position= raycastTarget
	
	debugLine.set_point_position(0,raycast_drill.position)
	#debugLine.set_point_position(1,(raycast_drill.target_position))
	
	
	if raycast_drill.is_colliding():
		var collider=raycast_drill.get_collider()
		var col_point = raycast_drill.get_collision_point()
		var extrudedpoint = col_point+ (raycast_drill.get_collision_normal()*-2) 
		debugLine.set_point_position(1,(extrudedpoint))

		
		debugLine.default_color=Color.RED
		debugLine.set_point_position(1,(to_local( col_point)))

		tilemap.set_cell(tilemap.local_to_map(tilemap.to_local(extrudedpoint)),-1,Vector2i(-1,-1),-1)

#		tilemap.set_cell(tilemap.local_to_map(tilemap.to_local(col_point)),-1,Vector2i(-1,-1),-1)

#figure out why tilemap removal isn't working

		#tilemap.erase_cell(tilemap.local_to_map(col_point))
		#tilemap.erase_cell(col_point)
		
		#debugDot.position=debugDot.to_local(col_point)
		
		
	else:
		debugLine.default_color=Color.GREEN
	
	
	
	#this code should.. 
	#get the position of the drill point
	#see if that drill is interacting with anything diggable 
	#if so - spawn a CRACK timer that ticks down, speed depending on block strength & drill upgrade lvl 
	#the crack timer can handle the destuction, but the player must be able to abort the crack timer if needed. 
	#I think i will spawn the crack timer in-world so that it is not affected by player position. 
	
	
	
	pass

func Update_Animations(newanim):
	
	if facingDir == Directions.LEFT:
		$AnimatedSprite2D.flip_h=true
	if facingDir == Directions.RIGHT:
		$AnimatedSprite2D.flip_h=false
	
	if newanim !=animstate:
		animstate=newanim
		$AnimatedSprite2D.animation=animstate
