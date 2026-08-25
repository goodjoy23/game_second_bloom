extends Node3D


func _ready() -> void:
	_build_environment()
	_build_room()
	_build_windows()
	_build_bookshelf()
	_build_counter()
	_build_tables()
	_build_decor()


func _build_environment() -> void:
	var environment := Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = Color("#10191d")
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("#9bb0b2")
	environment.ambient_light_energy = 0.52
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC

	var world_environment := WorldEnvironment.new()
	world_environment.environment = environment
	add_child(world_environment)

	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-54.0, -28.0, 0.0)
	sun.light_color = Color("#c8d3d2")
	sun.light_energy = 0.95
	sun.shadow_enabled = true
	add_child(sun)

	_add_warm_light(Vector3(-1.8, 3.3, -0.5), 5.4)
	_add_warm_light(Vector3(3.6, 3.0, -2.0), 4.2)


func _build_room() -> void:
	_add_box("Floor", Vector3(0.0, -0.12, 0.0), Vector3(14.0, 0.24, 8.4), Color("#493a31"), true)
	_add_box("BackWall", Vector3(0.0, 1.55, -4.2), Vector3(14.2, 3.2, 0.24), Color("#26363a"), true)
	_add_box("LeftWall", Vector3(-7.05, 1.35, 0.0), Vector3(0.24, 2.8, 8.4), Color("#302925"), true)
	_add_box("RightWall", Vector3(7.05, 1.35, 0.0), Vector3(0.24, 2.8, 8.4), Color("#302925"), true)
	_add_collision_box("FrontBoundary", Vector3(0.0, 0.8, 4.15), Vector3(14.0, 1.6, 0.2))

	for plank in range(-7, 8):
		_add_box(
			"FloorPlank",
			Vector3(float(plank), 0.015, 0.0),
			Vector3(0.025, 0.02, 8.1),
			Color(0.16, 0.11, 0.08, 0.42),
			false
		)

	_add_box("Rug", Vector3(-2.9, 0.025, 2.15), Vector3(4.0, 0.035, 1.95), Color("#344c49"), false)


func _build_windows() -> void:
	var window_positions: Array[float] = [-3.4, -0.7, 2.0]
	for window_x: float in window_positions:
		_add_box("WindowGlass", Vector3(window_x, 1.95, -4.055), Vector3(2.05, 1.35, 0.055), Color("#18323b"), false, Color("#10252d"))
		_add_box("WindowTop", Vector3(window_x, 2.68, -4.0), Vector3(2.22, 0.10, 0.14), Color("#80664d"), false)
		_add_box("WindowBottom", Vector3(window_x, 1.22, -4.0), Vector3(2.22, 0.11, 0.16), Color("#80664d"), false)
		_add_box("WindowLeft", Vector3(window_x - 1.07, 1.95, -4.0), Vector3(0.10, 1.55, 0.14), Color("#80664d"), false)
		_add_box("WindowRight", Vector3(window_x + 1.07, 1.95, -4.0), Vector3(0.10, 1.55, 0.14), Color("#80664d"), false)
		_add_box("WindowMiddle", Vector3(window_x, 1.95, -3.98), Vector3(0.07, 1.42, 0.12), Color("#80664d"), false)

		for drop in range(6):
			var drop_x: float = window_x - 0.82 + float(drop) * 0.32
			var drop_y: float = 1.48 + float((drop * 7) % 9) * 0.105
			_add_box("RainDrop", Vector3(drop_x, drop_y, -3.94), Vector3(0.018, 0.24, 0.018), Color("#7aa5af"), false, Color("#315a66"))


func _build_bookshelf() -> void:
	_add_box("Bookshelf", Vector3(-5.75, 1.05, -2.85), Vector3(1.75, 2.10, 0.58), Color("#513a2a"), true)
	var shelf_levels: Array[float] = [0.38, 0.88, 1.38, 1.88]
	for shelf_y: float in shelf_levels:
		_add_box("Shelf", Vector3(-5.75, shelf_y, -2.49), Vector3(1.86, 0.08, 0.64), Color("#271b14"), false)
	var book_colors := [Color("#8b493f"), Color("#bd9256"), Color("#4f706c"), Color("#705b78")]
	for row in range(4):
		for column in range(7):
			var book_height := 0.25 + float((row + column * 3) % 5) * 0.035
			_add_box(
				"Book",
				Vector3(-6.43 + float(column) * 0.22, 0.36 + float(row) * 0.5 + book_height * 0.5, -2.46),
				Vector3(0.14, book_height, 0.16),
				book_colors[(row + column) % book_colors.size()],
				false
			)


func _build_counter() -> void:
	_add_box("CounterBase", Vector3(5.25, 0.52, -2.75), Vector3(2.35, 1.04, 1.18), Color("#553c2b"), true)
	_add_box("CounterTop", Vector3(5.25, 1.10, -2.75), Vector3(2.55, 0.14, 1.34), Color("#926a45"), false)
	_add_box("CoffeeMachine", Vector3(5.65, 1.45, -3.02), Vector3(0.62, 0.68, 0.44), Color("#273033"), false)
	_add_box("CupStack", Vector3(4.62, 1.27, -2.85), Vector3(0.42, 0.30, 0.42), Color("#d7c7a7"), false)


func _build_tables() -> void:
	_add_table(Vector3(-0.65, 0.0, -0.72), Vector3(1.80, 0.0, 1.08), Color("#77573d"))
	_add_chair(Vector3(-1.85, 0.0, -0.72), 0.0)
	_add_chair(Vector3(0.55, 0.0, -0.72), 0.0)

	_add_table(Vector3(2.25, 0.0, 1.35), Vector3(1.55, 0.0, 0.92), Color("#6b4d37"))
	_add_chair(Vector3(1.20, 0.0, 1.35), 0.0)
	_add_chair(Vector3(3.30, 0.0, 1.35), 0.0)


func _add_table(table_position: Vector3, table_size: Vector3, color: Color) -> void:
	_add_box("TableTop", table_position + Vector3(0.0, 0.72, 0.0), Vector3(table_size.x, 0.14, table_size.z), color, true)
	var leg_signs: Array[float] = [-1.0, 1.0]
	for x_sign: float in leg_signs:
		for z_sign: float in leg_signs:
			_add_box(
				"TableLeg",
				table_position + Vector3(x_sign * (table_size.x * 0.38), 0.35, z_sign * (table_size.z * 0.34)),
				Vector3(0.12, 0.70, 0.12),
				Color("#30221b"),
				false
			)


func _add_chair(chair_position: Vector3, yaw: float) -> void:
	var chair := Node3D.new()
	chair.position = chair_position
	chair.rotation.y = yaw
	add_child(chair)
	_add_box_to(chair, "ChairSeat", Vector3(0.0, 0.42, 0.0), Vector3(0.48, 0.12, 0.48), Color("#332a25"))
	_add_box_to(chair, "ChairBack", Vector3(0.0, 0.72, 0.19), Vector3(0.48, 0.55, 0.10), Color("#4e392a"))


func _build_decor() -> void:
	_add_box("PlantPot", Vector3(4.15, 0.32, 2.70), Vector3(0.62, 0.64, 0.62), Color("#77513a"), true)
	var leaf_offsets: Array[Vector3] = [Vector3(-0.22, 0.84, 0.0), Vector3(0.20, 0.92, 0.05), Vector3(0.0, 1.08, -0.10)]
	for offset: Vector3 in leaf_offsets:
		_add_sphere("PlantLeaf", Vector3(4.15, 0.0, 2.70) + offset, 0.36, Color("#3f654c"))

	_add_box("CafeSign", Vector3(-5.85, 2.68, -4.0), Vector3(1.65, 0.36, 0.10), Color("#3d2b20"), false)


func _add_warm_light(light_position: Vector3, energy: float) -> void:
	var light := OmniLight3D.new()
	light.position = light_position
	light.light_color = Color("#f0b66d")
	light.light_energy = energy
	light.omni_range = 5.2
	light.shadow_enabled = true
	add_child(light)


func _add_box(
	node_name: String,
	box_position: Vector3,
	box_size: Vector3,
	color: Color,
	with_collision: bool,
	emission: Color = Color.TRANSPARENT
) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = box_position
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	box_mesh.material = _make_material(color, emission)
	mesh_instance.mesh = box_mesh
	add_child(mesh_instance)
	if with_collision:
		_add_collision_box("%sCollision" % node_name, box_position, box_size)
	return mesh_instance


func _add_box_to(
	parent: Node3D,
	node_name: String,
	local_position: Vector3,
	box_size: Vector3,
	color: Color
) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = local_position
	var box_mesh := BoxMesh.new()
	box_mesh.size = box_size
	box_mesh.material = _make_material(color)
	mesh_instance.mesh = box_mesh
	parent.add_child(mesh_instance)


func _add_sphere(node_name: String, sphere_position: Vector3, radius: float, color: Color) -> void:
	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = node_name
	mesh_instance.position = sphere_position
	var sphere := SphereMesh.new()
	sphere.radius = radius
	sphere.height = radius * 2.0
	sphere.material = _make_material(color)
	mesh_instance.mesh = sphere
	add_child(mesh_instance)


func _add_collision_box(node_name: String, box_position: Vector3, box_size: Vector3) -> void:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = box_position
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box_size
	collision.shape = shape
	body.add_child(collision)
	add_child(body)


func _make_material(color: Color, emission: Color = Color.TRANSPARENT) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.78
	if emission.a > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = 0.55
	return material
