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

const DOWN_TEXTURE := preload("res://assets/characters/kang_minwoo/frames/down.png")
const UP_TEXTURE := preload("res://assets/characters/kang_minwoo/frames/up.png")
const LEFT_TEXTURE := preload("res://assets/characters/kang_minwoo/frames/left.png")
const RIGHT_TEXTURE := preload("res://assets/characters/kang_minwoo/frames/right.png")

@onready var sprite: Sprite2D = $Sprite2D

var movement_enabled := true
var walk_phase := 0.0
var facing := "down"


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
	match facing:
		"up":
			sprite.texture = UP_TEXTURE
		"left":
			sprite.texture = LEFT_TEXTURE
		"right":
			sprite.texture = RIGHT_TEXTURE
		_:
			sprite.texture = DOWN_TEXTURE


func _is_inside_obstacle(point: Vector2) -> bool:
	for obstacle in OBSTACLES:
		if obstacle.grow(18.0).has_point(point):
			return true
	return false


func _reset_walk_bob() -> void:
	walk_phase = 0.0
	sprite.position.y = -36.0
