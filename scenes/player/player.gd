extends CharacterBody3D


const SPEED = 3.5
const JUMP_VELOCITY = 3

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var mesh = $"character-human2"
@onready var animation_player = $AnimationPlayer


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	if (velocity.x != 0 or velocity.z != 0):
		mesh.look_at(transform.origin - Vector3(velocity.x, 0, velocity.z), Vector3.UP)
		if velocity.y == 0:
			animation_player.play("walk")
		else:
			animation_player.play("static")
	elif velocity.y == 0:
		animation_player.play("idle")
	else:
		animation_player.play("static")

	move_and_slide()
