class_name PlayerController
extends CharacterBody3D

const WALK_SPEED := 4.1
const ACCELERATION := 18.0
const TURN_SPEED := 10.0
const WALK_BOB_HEIGHT := 0.045

@onready var sprite: Sprite3D = $PlayerSprite

var movement_enabled := true
var walk_phase := 0.0
var facing := "down"
var character_id := "kang_minwoo"
var direction_textures: Dictionary = {}


func configure_character(new_character_id: String) -> void:
	character_id = new_character_id
	direction_textures.clear()
	for direction in ["down", "up", "left", "right"]:
		var texture_path := "res://assets/characters/%s/frames/%s.png" % [character_id, direction]
		direction_textures[direction] = load(texture_path) as Texture2D
	facing = ""
	_set_facing("down")


func _physics_process(delta: float) -> void:
	if not movement_enabled:
		velocity = velocity.move_toward(Vector3.ZERO, ACCELERATION * delta)
		_reset_walk_bob()
		move_and_slide()
		return

	var input_vector := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y)
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	var target_velocity := direction * WALK_SPEED
	velocity.x = move_toward(velocity.x, target_velocity.x, ACCELERATION * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, ACCELERATION * delta)
	velocity.y = 0.0

	if not direction.is_zero_approx():
		var target_yaw := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, clampf(TURN_SPEED * delta, 0.0, 1.0))
		_update_facing(direction)
		walk_phase += delta * 12.0
		sprite.position.y = 0.96 + sin(walk_phase) * WALK_BOB_HEIGHT
	else:
		_reset_walk_bob()

	move_and_slide()


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not movement_enabled:
		velocity = Vector3.ZERO
		_reset_walk_bob()


func face_toward(target_position: Vector3) -> void:
	var direction := target_position - global_position
	direction.y = 0.0
	if direction.is_zero_approx():
		return
	rotation.y = atan2(direction.x, direction.z)
	_update_facing(direction)


func _update_facing(direction: Vector3) -> void:
	if absf(direction.x) > absf(direction.z):
		_set_facing("right" if direction.x > 0.0 else "left")
	else:
		_set_facing("down" if direction.z > 0.0 else "up")


func _set_facing(new_facing: String) -> void:
	if facing == new_facing:
		return
	facing = new_facing
	var texture := direction_textures.get(facing) as Texture2D
	if texture != null:
		sprite.texture = texture


func _reset_walk_bob() -> void:
	walk_phase = 0.0
	sprite.position.y = 0.96
