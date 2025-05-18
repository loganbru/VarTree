extends CharacterBody2D

var max_speed : float = 350.0
var acceleration : float = 600.0
var friction : float = 800.0

var current_speed : float = 0.0

var max_health : float = 200.0
var current_health : float = 200.0

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		current_health -= randf_range(1.0, 100.0)

func _physics_process(delta: float) -> void:
	var input_direction = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_direction.x += 1
	if Input.is_action_pressed("ui_left"):
		input_direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_direction.y += 1
	if Input.is_action_pressed("ui_up"):
		input_direction.y -= 1

	input_direction = input_direction.normalized()

	if input_direction != Vector2.ZERO:
		# Accelerate toward max speed
		velocity = velocity.move_toward(input_direction * max_speed, acceleration * delta)
	else:
		# Decelerate with friction
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Update current speed (scalar, not direction)
	current_speed = velocity.length()

	move_and_slide()
