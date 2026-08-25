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

	# 비 내리는 골목과 북카페 창을 추상적으로 그린 임시 배경.
	draw_rect(Rect2(Vector2.ZERO, viewport_size), Color("#17242c"))
	draw_rect(Rect2(0, viewport_size.y * 0.58, viewport_size.x, viewport_size.y * 0.42), Color("#2a2522"))
	draw_rect(Rect2(viewport_size.x * 0.08, viewport_size.y * 0.12, viewport_size.x * 0.84, viewport_size.y * 0.50), Color("#31434a"))
	draw_rect(Rect2(viewport_size.x * 0.10, viewport_size.y * 0.14, viewport_size.x * 0.38, viewport_size.y * 0.46), Color("#22363f"))
	draw_rect(Rect2(viewport_size.x * 0.52, viewport_size.y * 0.14, viewport_size.x * 0.38, viewport_size.y * 0.46), Color("#22363f"))
	draw_line(Vector2(viewport_size.x * 0.5, viewport_size.y * 0.12), Vector2(viewport_size.x * 0.5, viewport_size.y * 0.62), Color("#8b755c"), 7.0)

	# 오후의 따뜻한 실내 조명.
	for radius in range(260, 40, -28):
		var alpha := 0.006 + float(260 - radius) * 0.000035
		draw_circle(Vector2(viewport_size.x * 0.73, viewport_size.y * 0.40), radius, Color(0.95, 0.61, 0.30, alpha))

	# 창밖의 비. 숫자 기반 배치라 실행할 때마다 같은 분위기를 유지한다.
	for i in range(92):
		var x := fmod(float(i * 97) + elapsed * (115.0 + float(i % 7) * 9.0), viewport_size.x + 120.0) - 60.0
		var y := fmod(float(i * 53) + elapsed * (310.0 + float(i % 5) * 14.0), viewport_size.y * 0.62 + 90.0) - 45.0
		var length := 12.0 + float(i % 6) * 2.5
		draw_line(Vector2(x, y), Vector2(x - 6.0, y + length), Color(0.68, 0.82, 0.88, 0.24), 1.2)

	# 카페 바닥의 오후 네 시 빛.
	var floor_y := viewport_size.y * 0.72
	var light_points := PackedVector2Array([
		Vector2(viewport_size.x * 0.53, floor_y),
		Vector2(viewport_size.x * 0.89, floor_y),
		Vector2(viewport_size.x * 0.72, viewport_size.y),
		Vector2(viewport_size.x * 0.42, viewport_size.y),
	])
	draw_colored_polygon(light_points, Color(0.94, 0.66, 0.35, 0.08))

