extends CharacterBody2D

signal playerStoppedDrillingTile
signal newTileCrack

var animstate=""
enum Directions {LEFT, RIGHT, UP, DOWN}
enum States {IDLE, DRILLING, AIR}
var state = States.IDLE

var facingDir= Directions.RIGHT
@export var SPEED = 100.0
@export var DRILLSPEED= 40.0
@export var JUMP_VELOCITY = -100.0
var maxJumps: int =3
var jumpsMade:int =0
@export var jump_crystals: Array[AnimatedSprite2D]
var justJumped:bool=false

@onready var raycast_drill = $RayCast2D
@onready var debugLine= $DebugRaycastLine
@onready var tilemap: TileMapLayer = get_parent().get_node("TilemapEnvironment")
var facing_right: bool = true
var player_is_drilling_tile: bool = false
var drillDirection=Directions.RIGHT

var TileCrackScene = preload("res://TileCrack.tscn")


func _ready() -> void:
	Update_Animations("idle")
	debugLine.points.clear()
	debugLine.add_point(raycast_drill.position)
	debugLine.add_point((raycast_drill.target_position))
	

func _physics_process(delta: float) -> void:
	var newanim=animstate
	
	
	# Check for jump input and add velocity.
	if Input.is_action_just_pressed("jump"):  
		if is_on_floor() or jumpsMade <= maxJumps:
			
			velocity.y = JUMP_VELOCITY
			newanim= "jump"
			justJumped=true
			print_debug(jumpsMade)

			for index in jump_crystals.size():
				jump_crystals[index].show()
				if index+1>maxJumps-jumpsMade:
					jump_crystals[index].hide()
		jumpsMade+=1
	# Add the gravity to player and update anims depending on velocity
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y<=0:
			newanim= "jump"
		if velocity.y > 0:
			newanim= "fall"
	elif !justJumped:
		jumpsMade=0
		for n in jump_crystals:
			n.hide()
	else:
		justJumped=false


	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	if direction:
		if animstate=="drill_side_walk":
			velocity.x = direction * DRILLSPEED			
		else:
			velocity.x = direction * SPEED	
			
		if velocity.x > 0:
			facingDir=Directions.RIGHT
			facing_right=true
		elif velocity.x<0:
			facingDir=Directions.LEFT
			facing_right=false
		
		if is_on_floor():
			newanim="run"
			
	else:
		#if player is not moving - check if they're looking up or down
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if is_on_floor():
			
		
		#if not moving left/right, handle whether char should look up/down
		
			if Input.is_action_pressed("up"):
				facingDir=Directions.UP
				newanim="idle_up"
			elif  Input.is_action_pressed("down"):
				facingDir=Directions.DOWN
				newanim="idle_down"
			elif facing_right:
				facingDir=Directions.RIGHT
				newanim="idle"
			else:
				facingDir=Directions.LEFT
				newanim="idle"
				
		
	if is_on_floor() and Input.is_action_pressed ("drill"):
		
		match facingDir:
			Directions.RIGHT:
				if velocity.x > 0 or velocity.x<0:
					newanim="drill_side_walk"
				else: 	
					newanim="drill_side"
			Directions.LEFT:
				if velocity.x > 0 or velocity.x<0:
					newanim="drill_side_walk"
				else: 	
					newanim="drill_side"
					
			Directions.UP:
				newanim="drill_up"
			Directions.DOWN:
				newanim="drill_down"
				
		PlayerIsDrilling()
	else:
		player_is_drilling_tile =false
		playerStoppedDrillingTile.emit()
		#tells crack script to stop timer


	move_and_slide()
	Update_Animations(newanim)


func PlayerIsDrilling(): 
	
	var length:int=18
	var raycastTarget = Vector2i(0,0)
	match facingDir:
		Directions.LEFT:
			raycastTarget=Vector2(-length,0)			
		Directions.RIGHT:
			raycastTarget=Vector2(length,0)
		Directions.UP:
			raycastTarget=Vector2(0,-length)
		Directions.DOWN:
			raycastTarget=Vector2(0,length)
	
	raycast_drill.target_position= raycastTarget
	raycast_drill.force_raycast_update()
	debugLine.set_point_position(0,raycast_drill.position)	
	if raycast_drill.is_colliding(): 
		if not player_is_drilling_tile:
			player_is_drilling_tile=true
			drillDirection=facingDir
			
			var col_point = raycast_drill.get_collision_point()
			var extrudedpoint = col_point+ (raycast_drill.get_collision_normal()*-2.5) 
			
			newTileCrack.emit(extrudedpoint)
			
			debugLine.set_point_position(1,(extrudedpoint))
			#debugLine.default_color=Color.RED
			#debugLine.set_point_position(1,(to_local( col_point)))
		elif drillDirection != facingDir:
			player_is_drilling_tile =false
			playerStoppedDrillingTile.emit()
	else:
		player_is_drilling_tile=false
		debugLine.default_color=Color.GREEN		
	pass


func Update_Animations(newanim):

	if facingDir == Directions.LEFT or facingDir == Directions.RIGHT:
		$AnimatedSprite2D.flip_h = !facing_right

	
	if newanim !=animstate:
		animstate=newanim
		$AnimatedSprite2D.animation=animstate


func _on_player_collider_body_entered(body: Node2D) -> void:
	
	#Todo: Check which ore was collected
	#Todo: Cannot collect ore if the inventory is full
	#todo: If you want inventory management n free dropping of ores, then figure UX for that that does not suck 
	#todo: UI juice
	body.queue_free()
	
	pass # Replace with function body.
