extends CharacterBody2D

signal playerStoppedDrillingTile
signal newTileCrack

var animstate=""
enum Directions {LEFT, RIGHT, UP, DOWN}
enum States {IDLE, DRILLING, AIR, DEAD, DAMAGE}
var state = States.IDLE

var facingDir= Directions.RIGHT
var facing_right: bool = true

@export var SPEED = 100.0
@export var DRILLSPEED= 40.0
@export var JUMP_VELOCITY = -100.0

#Jump variables
var maxJumps: int =3
var jumpsMade:int =0
@export var jump_crystals: Array[AnimatedSprite2D]
var justJumped:bool=false

#Damage variables
var damageTimerCounter:float=0
@export var damageStunTime:float=0.2
@export var damageVelocity:float=100
@export var invincibilityTime:float=3.5
var invincibilityCounter:float=0
var invincible:bool=false

var player_is_drilling_tile: bool = false
var playerDrillingSolid:bool=false
var drillDirection=Directions.RIGHT

@onready var raycast_drill = $RayCast2D
@onready var debugLine= $DebugRaycastLine
@onready var tilemap: TileMapLayer = get_parent().get_node("TilemapEnvironment")
@onready var oreInventory = $"../Camera2D/InventoryHandler"
@onready var particles=$DrillingParticles
@onready var healthManager=$"../Camera2D/HealthUIHandler"

func _ready() -> void:
	Update_Animations("idle")
	debugLine.points.clear()
	debugLine.add_point(raycast_drill.position)
	debugLine.add_point((raycast_drill.target_position))
	

func _physics_process(delta: float) -> void:
	
		#debug test
	if Input.is_action_just_pressed("removeLight"):
		DealPlayerDamage(1)
	if Input.is_action_just_pressed("addLight"):
		healthManager.RefillHealth()
	
	#skips player physics update if in shop
	if GlobalVariables.playerStatus==GlobalVariables.playerStatusEnum.SHOP:
		return
		
		
	var newanim=animstate
	
	if !state==States.DAMAGE and !state==States.DEAD:
		newanim=RegularMovement(delta,newanim)
	elif state==States.DAMAGE:
		newanim=TakeDamageMovement(delta,newanim)
	elif state==States.DEAD:
		newanim=DeathMovement(delta, newanim)
		LoseInvincibility()
		newanim="dead"

	if invincible:
		invincibilityCounter+=delta
		if invincibilityCounter>invincibilityTime:
			LoseInvincibility()


	move_and_slide()
	Update_Animations(newanim)

	
func TakeDamageMovement(delta:float,currentAnim:String):
	velocity.y=-damageVelocity #this should be based on the direction of the threat
	
	damageTimerCounter+=delta
	if damageTimerCounter>=damageStunTime:
		state=States.IDLE
		
	if GlobalVariables.playerHealth<=0:
		PlayDead()
	#$DebugLabel.text="playerHealth: "+str(GlobalVariables.playerHealth)
	
	return "damage"

func PlayDead():
	if state==States.DEAD:
		return false
	state=States.DEAD
	oreInventory.PlayerDied()
	

func DeathMovement(delta:float,currentAnim:String):
	if not is_on_floor():
		velocity += get_gravity() * delta
	velocity.x = move_toward(velocity.x, 0, SPEED)

func RegularMovement(delta:float,currentAnim:String):
	var newanim=currentAnim
	# Check for jump input and add velocity.
	if Input.is_action_just_pressed("jump"):  
		if is_on_floor() or jumpsMade <= maxJumps:
			
			velocity.y = JUMP_VELOCITY
			newanim= "jump"
			justJumped=true

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
			if Input.is_action_pressed("down"):
				newanim= "fall_drilldown"
			else:
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

	return newanim

func PlayerIsDrilling(): 
	
	var length:int=18
	var raycastTarget = Vector2i(0,0)
	var rotationDegrees:int=0
	match facingDir:
		Directions.LEFT:
			raycastTarget=Vector2(-length,0)
			rotationDegrees=90
		Directions.RIGHT:
			raycastTarget=Vector2(length,0)
			rotationDegrees=270
		Directions.UP:
			raycastTarget=Vector2(0,-length)
			rotationDegrees=180
		Directions.DOWN:
			raycastTarget=Vector2(0,length)
			rotationDegrees=0
	

	raycast_drill.target_position= raycastTarget
	raycast_drill.force_raycast_update()
	debugLine.set_point_position(0,raycast_drill.position)	

	#align particles	
	particles.position=raycastTarget
	particles.rotation=deg_to_rad(rotationDegrees)
	
	if raycast_drill.is_colliding(): 
		#once the game knows it has a valid target, it will not recheck whether it's drilling the same thing every frame.
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
	
func DealPlayerDamage(amount:int):
	if state==States.DAMAGE or state==States.DEAD:
		return false
	state=States.DAMAGE
	
	damageTimerCounter=0
	
	invincible=true
	invincibilityCounter=0

	healthManager.TakeDamage(amount)
	
	pass

func LoseInvincibility():
	#only do once
	if !invincible:
		return false
		
	invincible=false
	$AnimatedSprite2D.self_modulate=Color(Color.WHITE,1)
	var collisions:Array[Node2D]= $CollisionDetection.get_overlapping_bodies()
	
	if collisions.size()>0:
		var colltype:abstract_collidable
		for n in collisions:
			colltype=n.GetCollType()
			if colltype.type==colltype.types.ENEMY:
				DealPlayerDamage(1)
	
	pass

func Update_Animations(newanim):

	var playerAnim:AnimatedSprite2D=$AnimatedSprite2D

	if playerDrillingSolid:
		if !player_is_drilling_tile:
			particles.emitting=false
			playerDrillingSolid=false


	if facingDir == Directions.LEFT or facingDir == Directions.RIGHT:
		playerAnim.flip_h = !facing_right

	if newanim !=animstate:
		animstate=newanim
		playerAnim.animation=animstate
			
	#Make player flash if they're invincible
	if invincible:
		var frequency:float = 25
		var magnitude:float=1
		var wave = cos(GlobalTime.time*frequency)
		
		var alpha:float
		alpha = 0.4
		if wave > 0:
			alpha=1.0
		playerAnim.self_modulate=Color(Color.WHITE,alpha)

		


func _on_tile_crack_player_drilling_solid() -> void:
	particles.emitting=true
	playerDrillingSolid=true		

	pass # Replace with function body.

func _on_player_collider_body_entered(body: Node2D) -> void:
	
	var collider:abstract_collidable= body.GetCollType()
	
	#"match collider:
	if collider.type==collider.types.ENEMY:
		if !invincible:
			DealPlayerDamage(1)
	
	if collider.type==collider.types.ORE:
		var oretype = body.oreType
		if oreInventory.AddOreRequest(oretype):
			body.queue_free()


	#var ore := body as abstract_ore

	#Todo: Check which ore was collected
	#Todo: Cannot collect ore if the inventory is full
	#todo: If you want inventory management n free dropping of ores, then figure UX for that that does not suck 
	#todo: UI juice
	
	pass # Replace with function body.
