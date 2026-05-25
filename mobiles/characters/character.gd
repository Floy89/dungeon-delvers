extends CharacterBody3D


@export_group("Physics")
@export var speed = 5.0
@export var acceleration = 4.0
@export var mouse_sensitivity = 0.0075
@export var rotation_speed = 12.0

@onready var spring_arm = $SpringArm3D
@onready var model = $Rig
@onready var anim_tree = $AnimationTree

var direction := Vector3.ZERO

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Determine movement
	get_input()
	
	#Move the Character
	velocity = lerp(velocity, direction * speed, acceleration * delta)
	do_animation()
	move_and_slide()
	if velocity.length() > 1.0: rotate_to(delta) # If the player is moving, line the player up with the camera


func _unhandled_input(event):
	if event is InputEventMouseMotion:
		spring_arm.rotation.x -= event.relative.y * mouse_sensitivity
		spring_arm.rotation_degrees.x = clamp(spring_arm.rotation_degrees.x, -90.0, 30.0)
		spring_arm.rotation.y -= event.relative.x * mouse_sensitivity


# Gets input from the player and updates velocity.
func get_input() -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	update_velocity(input_dir)


# Directly updates the velocity. Is used by player input, and can be used
# to manually move the character for cutscene scripting or unit testing.
func update_velocity(input_dir: Vector2) -> void:
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).rotated(Vector3.UP, spring_arm.rotation.y)
	
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


# Gets a blend for the Idle/Walk/Run State to play.
func do_animation() -> void:
	var vl = velocity * model.transform.basis
	anim_tree.set("parameters/IWR/blend_position", Vector2(vl.x, -vl.z) / speed)


# Rotates the character to face the direction of the passed SpringArm3D.
func rotate_to(delta) -> void:
	model.rotation.y = lerp_angle(model.rotation.y, spring_arm.rotation.y, rotation_speed * delta)
