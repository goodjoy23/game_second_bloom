extends Control

var elapsed := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	queue_redraw()


func _draw() -> void:
	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	_draw_room(viewport_size)
	_draw_windows(viewport_size)
	_draw_bookshelves()
	_draw_counter()
	_draw_tables()
	_draw_floor_details(viewport_size)
	_draw_ambient_light(viewport_size)


func _draw_room(viewport_size: Vector2) -> void:
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("#111a1d"))
	draw_rect(Rect2(24.0, 92.0, viewport_size.x - 48.0, viewport_size.y - 116.0), Color("#3a302b"))
	draw_rect(Rect2(24.0, 92.0, viewport_size.x - 48.0, 146.0), Color("#27373b"))
	draw_rect(Rect2(24.0, 228.0, viewport_size.x - 48.0, viewport_size.y - 252.0), Color("#46372f"))
	draw_rect(Rect2(24.0, 228.0, viewport_size.x - 48.0, 8.0), Color("#211d1a"))

	for y in range(246, int(viewport_size.y - 22.0), 34):
		draw_line(Vector2(25.0, float(y)), Vector2(viewport_size.x - 25.0, float(y)), Color("#59463a"), 1.0)
	for x in range(38, int(viewport_size.x - 24.0), 86):
		draw_line(Vector2(float(x), 236.0), Vector2(float(x) - 34.0, viewport_size.y - 24.0), Color(0.18, 0.13, 0.11, 0.20), 1.0)

	draw_rect(Rect2(24.0, viewport_size.y - 28.0, viewport_size.x - 48.0, 4.0), Color("#201b18"))


func _draw_windows(viewport_size: Vector2) -> void:
	var windows := [
		Rect2(248.0, 112.0, 206.0, 104.0),
		Rect2(476.0, 112.0, 206.0, 104.0),
		Rect2(704.0, 112.0, 206.0, 104.0),
	]
	for window in windows:
		draw_rect(window.grow(6.0), Color("#171c1d"))
		draw_rect(window, Color("#1b3037"))
		draw_rect(Rect2(window.position + Vector2(0.0, window.size.y - 19.0), Vector2(window.size.x, 19.0)), Color("#18262a"))
		draw_line(Vector2(window.get_center().x, window.position.y), Vector2(window.get_center().x, window.end.y), Color("#76614d"), 4.0)
		draw_line(Vector2(window.position.x, window.get_center().y), Vector2(window.end.x, window.get_center().y), Color("#76614d"), 3.0)

		for i in range(18):
			var rain_x: float = window.position.x + fmod(float(i * 41) + elapsed * (26.0 + float(i % 4) * 4.0), window.size.x - 8.0) + 4.0
			var rain_y: float = window.position.y + fmod(float(i * 29) + elapsed * (82.0 + float(i % 5) * 6.0), window.size.y - 16.0)
			draw_line(Vector2(rain_x, rain_y), Vector2(rain_x - 3.0, rain_y + 12.0), Color(0.66, 0.82, 0.87, 0.34), 1.0)

	draw_rect(Rect2(242.0, 218.0, 674.0, 9.0), Color("#17191a"))
	draw_circle(Vector2(viewport_size.x * 0.72, 170.0), 4.0, Color("#d7b373"))


func _draw_bookshelves() -> void:
	draw_rect(Rect2(42.0, 126.0, 182.0, 190.0), Color("#201b18"))
	draw_rect(Rect2(50.0, 134.0, 166.0, 174.0), Color("#513b2b"))
	for shelf_y in [174.0, 218.0, 262.0, 306.0]:
		draw_rect(Rect2(48.0, shelf_y, 170.0, 7.0), Color("#251c16"))

	var book_colors := [Color("#8b493f"), Color("#c0975b"), Color("#516c68"), Color("#6f5a76"), Color("#a86b43")]
	for row in range(4):
		for column in range(9):
			var book_height := 22.0 + float((row * 7 + column * 5) % 14)
			var book_x := 57.0 + float(column) * 17.0
			var shelf_bottom := 174.0 + float(row) * 44.0
			draw_rect(Rect2(book_x, shelf_bottom - book_height, 11.0, book_height), book_colors[(row + column) % book_colors.size()])
	draw_rect(Rect2(34.0, 316.0, 198.0, 10.0), Color(0.06, 0.04, 0.03, 0.50))


func _draw_counter() -> void:
	draw_rect(Rect2(1000.0, 128.0, 238.0, 190.0), Color("#1d1917"))
	draw_rect(Rect2(1008.0, 138.0, 222.0, 171.0), Color("#59402e"))
	draw_rect(Rect2(992.0, 278.0, 250.0, 41.0), Color("#32241d"))
	draw_rect(Rect2(986.0, 271.0, 258.0, 13.0), Color("#8b6847"))
	for x in [1024.0, 1080.0, 1136.0, 1192.0]:
		draw_line(Vector2(x, 286.0), Vector2(x, 309.0), Color("#6b4d37"), 2.0)

	draw_rect(Rect2(1042.0, 188.0, 50.0, 60.0), Color("#202628"))
	draw_rect(Rect2(1048.0, 194.0, 38.0, 42.0), Color("#4e5a59"))
	draw_circle(Vector2(1067.0, 209.0), 8.0, Color("#c8b07b"))
	draw_rect(Rect2(1144.0, 236.0, 34.0, 24.0), Color("#d3c4a3"))
	draw_rect(Rect2(1182.0, 241.0, 22.0, 19.0), Color("#85705c"))


func _draw_tables() -> void:
	_draw_table(Rect2(446.0, 250.0, 210.0, 130.0), Color("#6f5138"))
	_draw_chair(Vector2(420.0, 292.0), true)
	_draw_chair(Vector2(682.0, 292.0), true)

	_draw_table(Rect2(710.0, 332.0, 190.0, 116.0), Color("#654934"))
	_draw_chair(Vector2(682.0, 368.0), true)
	_draw_chair(Vector2(926.0, 368.0), true)

	draw_circle(Vector2(546.0, 306.0), 15.0, Color("#d7c9ab"))
	draw_circle(Vector2(546.0, 306.0), 9.0, Color("#49372c"))
	draw_rect(Rect2(775.0, 374.0, 48.0, 30.0), Color("#d0b98c"))
	draw_line(Vector2(781.0, 382.0), Vector2(816.0, 382.0), Color("#8f7756"), 1.0)
	draw_line(Vector2(781.0, 389.0), Vector2(810.0, 389.0), Color("#8f7756"), 1.0)


func _draw_table(rect: Rect2, color: Color) -> void:
	draw_rect(Rect2(rect.position + Vector2(8.0, 11.0), rect.size), Color(0.05, 0.03, 0.02, 0.34))
	draw_style_box(_rounded_box(color, Color("#97704d"), 3, 18), rect)
	draw_line(rect.position + Vector2(22.0, rect.size.y - 15.0), rect.position + Vector2(22.0, rect.size.y + 12.0), Color("#2d211b"), 8.0)
	draw_line(rect.position + Vector2(rect.size.x - 22.0, rect.size.y - 15.0), rect.position + Vector2(rect.size.x - 22.0, rect.size.y + 12.0), Color("#2d211b"), 8.0)


func _draw_chair(center: Vector2, faces_side: bool) -> void:
	var chair_size := Vector2(34.0, 58.0) if faces_side else Vector2(58.0, 34.0)
	draw_style_box(
		_rounded_box(Color("#2b2522"), Color("#72523a"), 2, 8),
		Rect2(center - chair_size * 0.5, chair_size)
	)


func _draw_floor_details(viewport_size: Vector2) -> void:
	draw_style_box(
		_rounded_box(Color(0.19, 0.30, 0.29, 0.52), Color(0.44, 0.55, 0.49, 0.35), 2, 42),
		Rect2(238.0, 440.0, 390.0, 164.0)
	)
	for x in range(270, 620, 42):
		draw_line(Vector2(float(x), 454.0), Vector2(float(x) - 38.0, 588.0), Color(0.63, 0.73, 0.64, 0.08), 8.0)

	draw_circle(Vector2(936.0, 520.0), 38.0, Color(0.09, 0.12, 0.09, 0.55))
	draw_circle(Vector2(936.0, 512.0), 29.0, Color("#31483b"))
	draw_circle(Vector2(920.0, 496.0), 18.0, Color("#3e5d49"))
	draw_circle(Vector2(952.0, 494.0), 17.0, Color("#45654d"))
	draw_rect(Rect2(924.0, 518.0, 24.0, 32.0), Color("#6d4d35"))

	draw_line(Vector2(292.0, 620.0), Vector2(1110.0, 620.0), Color(0.82, 0.63, 0.39, 0.13), 2.0)
	draw_rect(Rect2(64.0, 98.0, 144.0, 24.0), Color("#b47d43"))
	draw_rect(Rect2(68.0, 102.0, 136.0, 16.0), Color("#3d2b20"))

	var font := ThemeDB.fallback_font
	draw_string(font, Vector2(82.0, 115.0), "BOOK CAFE  ·  4 PM", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 13, Color("#ead4ad"))
	draw_string(font, Vector2(viewport_size.x - 226.0, 352.0), "COUNTER", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 12, Color(0.87, 0.77, 0.61, 0.58))


func _draw_ambient_light(viewport_size: Vector2) -> void:
	for radius in range(210, 30, -24):
		var alpha := 0.007 + float(210 - radius) * 0.000035
		draw_circle(Vector2(570.0, 350.0), float(radius), Color(1.0, 0.69, 0.35, alpha))
	for radius in range(170, 30, -22):
		var alpha := 0.006 + float(170 - radius) * 0.000035
		draw_circle(Vector2(882.0, 295.0), float(radius), Color(1.0, 0.71, 0.40, alpha))

	draw_rect(Rect2(Vector2.ZERO, Vector2(viewport_size.x, 84.0)), Color(0.03, 0.05, 0.06, 0.48))


func _rounded_box(color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	return style
