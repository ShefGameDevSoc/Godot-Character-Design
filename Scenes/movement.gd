extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# WORK YOUR MAGIC HERE!
#////////////////////////////////////////////////////////////////
# p.s the speed values usually have to be quite big.
@export var SPEED: float = 0.0           # top speed
@export var ACCELERATION: float = 0.0   # how fast we speed up
@export var FRICTION: float = 0.0        # how fast we slow down (lower = floatier)
@export var JUMP_VELOCITY: float = 0.0  # THIS NEEDS TO BE NEGATIVE TO HAVE AN EFFECT
@export var GRAVITY_SCALE: float = 0.5      # < 1.0 = more floaty
@export var ROLL_SPEED: float = 0.0
#////////////////////////////////////////////////////////////////
var is_rolling: bool = false
var roll_direction: float = 0.0

func _ready() -> void:
	# So we know when the roll animation has finished
	animation_player.animation_finished.connect(_on_animation_finished)
	
	# ENLARGE YOUR KNIGHT HERE!
	# global_scale *= Vector2(4,4)


func _physics_process(delta: float) -> void:
	# --- Gravity (scaled for floatiness) ---
	if not is_on_floor():
		velocity += get_gravity() * GRAVITY_SCALE * delta

	# --- If we're rolling, ignore normal movement input ---
	if is_rolling:
		velocity.x = roll_direction * ROLL_SPEED
		move_and_slide()
		return

	# --- Normal horizontal movement with acceleration / friction ---
	var direction := Input.get_axis("move_left", "move_right")

	if direction != 0.0:
		# Accelerate towards target speed instead of snapping
		var target_speed := direction * SPEED
		velocity.x = move_toward(velocity.x, target_speed, ACCELERATION * delta)

		# Run animation
		animated_sprite_2d.play("run")

		# Flip sprite based on direction
		animated_sprite_2d.flip_h = direction < 0
	else:
		# Slowly ease back to 0 instead of instantly stopping
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)

		# Idle animation when on ground & not moving
		if is_on_floor():
			animated_sprite_2d.play("idle")

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# --- Roll input ---
	if Input.is_action_just_pressed("roll") and is_on_floor():
		start_roll()

	move_and_slide()


func start_roll() -> void:
	# Enter roll state, lock in direction and start animation
	is_rolling = true

	# Roll in the direction the character is facing
	roll_direction = -1.0 if animated_sprite_2d.flip_h else 1.0

	# Play the AnimationPlayer animation (must be called "roll_anim" in the editor)
	animation_player.play("roll_anim")

	# If you're using the AnimatedSprite2D's animations directly instead, you can also do:
	# animated_sprite_2d.play("roll")


func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "roll_anim":
		is_rolling = false
