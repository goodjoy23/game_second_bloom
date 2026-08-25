class_name PlayerController
extends CharacterBody2D

const WALK_SPEED := 185.0
const WALK_BOB_HEIGHT := 1.5
const WORLD_BOUNDS := Rect2(76.0, 132.0, 1128.0, 500.0)
const OBSTACLES: Array[Rect2] = [
	Rect2(42.0, 126.0, 182.0, 190.0),
	Rect2(1000.0, 128.0, 238.0, 190.0),
	Rect2(446.0, 250.0, 210.0, 130.0),
	Rect2(710.0, 332.0, 190.0, 116.0),
]

@onready var sprite: Sprite2D = $PlayerSprite

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
		velocity = Vector2.ZERO
		_reset_walk_bob()
		return

	var direction := _read_direction()
	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	var previous_position := global_position
	velocity = direction * WALK_SPEED
	move_and_slide()
	global_position.x = clampf(global_position.x, WORLD_BOUNDS.position.x, WORLD_BOUNDS.end.x)
	global_position.y = clampf(global_position.y, WORLD_BOUNDS.position.y, WORLD_BOUNDS.end.y)

	if _is_inside_obstacle(global_position):
		global_position = previous_position

	if direction.is_zero_approx():
		_reset_walk_bob()
	else:
		_update_facing(direction)
		walk_phase += delta * 13.0
		sprite.position.y = -36.0 + sin(walk_phase) * WALK_BOB_HEIGHT


func set_movement_enabled(enabled: bool) -> void:
	movement_enabled = enabled
	if not movement_enabled:
		velocity = Vector2.ZERO
		_reset_walk_bob()


func face_toward(target_position: Vector2) -> void:
	var direction := target_position - global_position
	if absf(direction.x) > absf(direction.y):
		_set_facing("right" if direction.x > 0.0 else "left")
	else:
		_set_facing("down" if direction.y > 0.0 else "up")


func _read_direction() -> Vector2:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if Input.is_key_pressed(KEY_A):
		direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		direction.y += 1.0
	return direction.limit_length(1.0)


func _update_facing(direction: Vector2) -> void:
	if absf(direction.x) > absf(direction.y):
		_set_facing("right" if direction.x > 0.0 else "left")
	else:
		_set_facing("down" if direction.y > 0.0 else "up")


func _set_facing(new_facing: String) -> void:
	if facing == new_facing:
		return
	facing = new_facing
	var texture := direction_textures.get(facing) as Texture2D
	if texture != null:
		sprite.texture = texture


func _is_inside_obstacle(point: Vector2) -> bool:
	for obstacle in OBSTACLES:
		if obstacle.grow(18.0).has_point(point):
			return true
	return false


func _reset_walk_bob() -> void:
	walk_phase = 0.0
	sprite.position.y = -36.0
