extends CharacterBody2D

signal playerStoppedDrillingTile
signal signal_IsDrillingTileChanged(value:bool)
signal newTileCrack

var animstate=""
enum Directions {LEFT, RIGHT, UP, DOWN}
enum States {IDLE, DRILLING, AIR, DEAD, DAMAGE, DEBUG_GHOST,PAUSE}
var state = States.IDLE

var facingDir= Directions.RIGHT
var facing_right: bool = true

@export var SPEED = 100.0
@export var DRILLSPEED= 40.0
@export var JUMP_VELOCITY = -100.0

#Jump variables
var maxJumps: int =2
var jumpsMade:int =0
@export var jump_crystals: Array[AnimatedSprite2D]
var justJumped:bool=false
var airborne:bool=false
var heavy:bool=false

#Damage variables
var damageTimerCounter:float=0
@export var damageStunTime:float=0.2
@export var damageVelocity:float=100
@export var invincibilityTime:float=3.5
var invincibilityCounter:float=0
var invincible:bool=false

var playerIsDrilling:bool=false
var playerIsOnLeftEdge:bool=false
var playerIsOnRightEdge:bool=false
var player_is_drilling_tile: bool = false:
	get:
		return player_is_drilling_tile
	set(value):
		player_is_drilling_tile=value
		signal_IsDrillingTileChanged.emit(player_is_drilling_tile)
var playerDrillingSolid:bool=false
var drillDirection=Directions.RIGHT

#Colliders
@onready var collider_airborne=$Collider_airborne
@onready var collider_grounded=$Collider_grounded

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
	collider_airborne.disabled=true
	collider_grounded.disabled=false
	
	

func _physics_process(delta: float) -> void:
	
		#debug test
	if Input.is_action_just_pressed("removeLight"):
		DealPlayerDamage(1)
	if Input.is_action_just_pressed("addLight"):
		healthManager.RefillHealth()
		
	if Input.is_action_just_pressed("debug_1"):
		
		if state==States.DEBUG_GHOST:
			SetDebugMoveActive(false)
		else:
			SetDebugMoveActive(true)

	if Input.is_action_just_pressed("debug_2"):
		
		if !state==States.PAUSE:
			state=States.PAUSE
		else:
			state=States.IDLE	
		
	#skips player physics update if in shop
	if GlobalVariables.playerStatus==GlobalVariables.playerStatusEnum.SHOP:
		return
		
	if state==States.PAUSE:
		return

	var newanim=animstate
	
	if state==States.DEBUG_GHOST:
		DebugGhostMovement(delta,newanim)
		move_and_slide()
		return
	

	
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
	
func SetDebugMoveActive(active:bool):
	
	if active:
		#If mode is not active yet, perform first time setup
		if state!=States.DEBUG_GHOST:
			state=States.DEBUG_GHOST
			collider_airborne.disabled=true
			collider_grounded.disabled=true
			
			$GhostModeInfo.show()
	else:
		if state==States.DEBUG_GHOST:
			collider_airborne.disabled=false
			$GhostModeInfo.hide()
			state=States.IDLE

func DebugGhostMovement(delta:float,currentAnim:String):

	
	var directionX := Input.get_axis("left", "right")
	var directionY:=Input.get_axis("up","down")
	
	velocity.x=directionX*SPEED
	velocity.y=directionY*SPEED
	
	pass

func RegularMovement(delta:float,currentAnim:String):
	var newanim=currentAnim
	
	if Input.is_action_just_pressed("interact"):
				
		oreInventory.DropOresRequest(global_position,Vector2(0,0)) 
		heavy=false
	
	# Check for jump input and add velocity.
	if Input.is_action_just_pressed("jump"):  
		if is_on_floor() or jumpsMade <= maxJumps or !heavy:
			
			if is_on_floor():
				SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_JUMP)
			else:
				SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_JUMP_MIDAIR)
			velocity.y = JUMP_VELOCITY
			newanim= "jump"
			justJumped=true
			
			if heavy:
				for index in jump_crystals.size():
					jump_crystals[index].show()
					if index+1>maxJumps-jumpsMade:
						jump_crystals[index].hide()
				jumpsMade+=1
			else:
				SetLightEffectActive(true)
				for n in jump_crystals:
					n.hide()
	
	# Add the gravity to player and update anims depending on velocity
	if not is_on_floor():
		collider_airborne.disabled=false
		collider_grounded.disabled=true
		
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
		SetLightEffectActive(false)
		for n in jump_crystals:
			n.hide()
	else:
		justJumped=false

	if is_on_floor() && airborne:
		SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_LAND)
		airborne=false
	if !is_on_floor():
		airborne=true
		
	#change collisions based on where player is
	collider_airborne.disabled=is_on_floor()
	collider_grounded.disabled=!is_on_floor()

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	if direction:
		#Play footstep sound loop
	
			
		var minclamp:float=-1
		var maxclamp:float=1
		
		if playerIsDrilling:
			if playerIsOnRightEdge:
				maxclamp=0
			elif playerIsOnLeftEdge:
				minclamp=0
		
		if animstate=="drill_side_walk":			
			velocity.x = clampf( direction,	minclamp,maxclamp) * DRILLSPEED
		
		else:
			velocity.x = clampf( direction,minclamp,maxclamp) * SPEED
			
		if velocity.x > 0:
			facingDir=Directions.RIGHT
			facing_right=true
		elif velocity.x<0:
			facingDir=Directions.LEFT
			facing_right=false
		
		if is_on_floor():
			newanim="run"
			
	else:
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
		playerIsDrilling=false
		playerStoppedDrillingTile.emit()
		#tells crack script to stop timer

	return newanim


func PlayerIsDrilling(): 

	playerIsDrilling=true
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
	var collisions:Array[Node2D]= $Detector.get_overlapping_bodies()
	
	if collisions.size()>0:
		var colltype:abstract_collidable
		for n in collisions:
			colltype=n.GetCollType()
			if colltype.type==colltype.types.ENEMY:
				DealPlayerDamage(1)
	
	pass

func SetLightEffectActive(active:bool):
	var lightEffect:AnimatedSprite2D=$anim_LightEffect
	
	if active:
		lightEffect.show()
		$JumpParticles.emitting=true
	else:
		lightEffect.hide()
		$JumpParticles.emitting=false

	if facingDir == Directions.LEFT or facingDir == Directions.RIGHT:
		lightEffect.flip_h = !facing_right

func Update_Animations(newanim):

	var playerAnim:AnimatedSprite2D=$AnimatedSprite2D

	if playerDrillingSolid:
		if !player_is_drilling_tile:
			particles.emitting=false
			playerDrillingSolid=false


	if facingDir == Directions.LEFT or facingDir == Directions.RIGHT:
		playerAnim.flip_h = !facing_right
		$anim_LightEffect.flip_h = !facing_right



	if newanim !=animstate:
		animstate=newanim
		playerAnim.animation=animstate
	

	#TODO: Consider only calling this when relevant
	
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

func _on_animated_sprite_2d_animation_looped() -> void:
	if animstate=="run":
		if randf()>0.5:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_FOOTSTEP_ONE)
		else:
			SoundManager.PlaySoundAtLocation(global_position,abstract_SoundEffectSetting.SoundEffectEnum.PLAYER_FOOTSTEP_TWO)

	
	pass # Replace with function body.
	

func _on_tile_crack_material_changed(terrain: abstract_terrain_info) -> void:
	if terrain.terrainIdentifier==0: #Equals SOLID
		particles.emitting=true
		playerDrillingSolid=true		

	pass # Replace with function body.



func _on_block_below_checker_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	
	if $BlockBelowChecker.get_overlapping_bodies().size()<=0:
		
		var blockleft:bool= $BlockBelowCheck_LEFT.get_overlapping_bodies().size()>0 
		var blockRight:bool= $BlockBelowCheck_RIGHT.get_overlapping_bodies().size()>0 
		var print=""

		if blockleft and !blockRight:
			playerIsOnRightEdge=true
			playerIsOnLeftEdge=false
		
		if !blockleft and blockRight:
			playerIsOnRightEdge=false
			playerIsOnLeftEdge=true

		#$DebugLabel.text=print
	pass # Replace with function body.


func _on_block_below_checker_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if $BlockBelowChecker.get_overlapping_bodies().size()>=0:
		playerIsOnRightEdge=false
		playerIsOnLeftEdge=false


	pass # Replace with function body.


func _on_detector_body_entered(body: Node2D) -> void:
	var collider:abstract_collidable= body.GetCollType()
	
	#"match collider:
	if collider.type==collider.types.ENEMY:
		if !invincible && state!=States.DEBUG_GHOST:
			DealPlayerDamage(1)
	
	if collider.type==collider.types.ORE:
		
		if !body.cooldown:
			var oretype = body.oreType
			if oreInventory.AddOreRequest(oretype):
				body.queue_free()
				#Used to check if player can fly high
				heavy=true 

				
