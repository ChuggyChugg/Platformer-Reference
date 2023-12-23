extends CharacterBody2D

@export var movement_data : MovementData = preload("res://Resources/DefaultMovementStats.tres")

# gravity from project settings
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var change_animation_set = false

@onready var sprite = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_pos = global_position
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var jump_sound = $Jump_sound

func _physics_process(delta):
	var input_axis = Input.get_axis("left","right")
	apply_gravity(delta)
	handle_Movement(input_axis, delta)
	apply_friction(input_axis, delta)
	update_animation(input_axis)
	var was_on_floor = is_on_floor()
	move_and_slide()
	detect_rigidbody()
	coyote_jump(was_on_floor)
	buffer_jump(was_on_floor)

# Handles all movement (y velocity and x velocity)
# I just like to organise group of functions inside of a singular functions
func handle_Movement(input_axis, delta):
	handle_jump()
	handle_acceleration(input_axis, delta)
	handle_air_acceleration(input_axis, delta)

func coyote_jump(was_on_floor):
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_jump_timer.start()

func buffer_jump(was_on_floor):
	if not was_on_floor and is_on_floor() and velocity.y <= 0:
		jump_buffer_timer.start()

# Vertical Movement
func handle_jump():
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			jump_sound.play()
	# Half Jump
	elif not is_on_floor() and jump_buffer_timer.time_left > 0.0:
		if Input.is_action_just_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			jump_sound.play()
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2

# Horizontal Movement
func handle_acceleration(input_axis, delta):
	if not is_on_floor(): return
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.acceleration * delta)

func handle_air_acceleration(input_axis, delta):
	if is_on_floor(): return
	if input_axis:
		velocity.x = move_toward(velocity.x, movement_data.speed * input_axis, movement_data.air_acceleration * delta)

func apply_friction(input_axis, delta):
	if input_axis == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(input_axis, delta):
	if input_axis == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x , 0, movement_data.air_resistance * delta)

func apply_gravity(delta):
	if not is_on_floor():
		velocity.y += gravity * movement_data.gravity_scale * delta

# changes animation by input and position
func update_animation(input_axis):
	# Run Animation
	if input_axis != 0:
		sprite.flip_h = (input_axis < 0)
		if change_animation_set:
			sprite.play("magical_run")
		else:
			sprite.play("Run")
	else:
		if change_animation_set:
			sprite.play("magical_idle")
		else:
			sprite.play("Idle")
	# Jump animation
	if not is_on_floor():
		if change_animation_set:
			sprite.play("magical_jump")
		else:
			sprite.play("Jump")

func detect_rigidbody():
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_impulse(-c.get_normal() * movement_data.push_force)

func _on_hurt_box_area_entered(_area):
	get_tree().reload_current_scene()

func _on_power_upbox_area_entered(area):
	if area.is_in_group("small_gifts"):
		movement_data = preload("res://Resources/HigherJumpMovementStats.tres")
		change_animation_set = true
