extends Control

const CHAPTER_PATH := "res://data/chapter_01.json"

@onready var chapter_label: Label = %ChapterLabel
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var restart_button: Button = %RestartButton
@onready var load_button: Button = %LoadButton
@onready var minwoo_card: PanelContainer = %MinwooCard
@onready var seojeong_card: PanelContainer = %SeojeongCard
@onready var minwoo_mood: Label = %MinwooMood
@onready var seojeong_mood: Label = %SeojeongMood
@onready var dialogue_panel: PanelContainer = %DialoguePanel
@onready var speaker_label: Label = %SpeakerLabel
@onready var dialogue_text: RichTextLabel = %DialogueText
@onready var feedback_label: Label = %FeedbackLabel
@onready var choice_box: VBoxContainer = %ChoiceBox
@onready var status_label: Label = %StatusLabel
@onready var continue_button: Button = %ContinueButton
@onready var typewriter_timer: Timer = %TypewriterTimer

var chapter: Dictionary = {}
var nodes: Dictionary = {}
var current_node_id := ""
var next_node_id := ""
var current_full_text := ""
var is_typing := false
var visited: Dictionary = {}


func _ready() -> void:
	_apply_visual_style()
	_connect_signals()
	if not _load_chapter_data():
		_show_fatal_error("제1장 데이터를 불러오지 못했습니다.")
		return
	load_button.visible = GameState.has_save()
	_start_new_chapter()


func _connect_signals() -> void:
	restart_button.pressed.connect(_start_new_chapter)
	load_button.pressed.connect(_continue_saved_chapter)
	continue_button.pressed.connect(_advance)
	typewriter_timer.timeout.connect(_on_typewriter_tick)
	GameState.state_changed.connect(_update_status)


func _load_chapter_data() -> bool:
	if not FileAccess.file_exists(CHAPTER_PATH):
		return false
	var file := FileAccess.open(CHAPTER_PATH, FileAccess.READ)
	if file == null:
		return false
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	chapter = parsed
	nodes.clear()
	for item in chapter.get("nodes", []):
		if typeof(item) == TYPE_DICTIONARY and item.has("id"):
			nodes[str(item["id"])] = item
	chapter_label.text = str(chapter.get("title", "제1장"))
	return not nodes.is_empty()


func _start_new_chapter() -> void:
	GameState.reset()
	visited.clear()
	feedback_label.text = ""
	_play_node(str(chapter.get("start", "")))


func _continue_saved_chapter() -> void:
	var save_data := GameState.load_progress()
	var saved_node := str(save_data.get("node_id", chapter.get("start", "")))
	if not nodes.has(saved_node):
		saved_node = str(chapter.get("start", ""))
	feedback_label.text = "저장된 장면에서 이어갑니다."
	_play_node(saved_node)


func _play_node(node_id: String) -> void:
	if not nodes.has(node_id):
		_show_fatal_error("연결되지 않은 장면입니다: %s" % node_id)
		return

	current_node_id = node_id
	visited[node_id] = true
	var node: Dictionary = nodes[node_id]
	GameState.add_flags(Array(node.get("flags", [])))
	GameState.save_progress(node_id)
	load_button.visible = true
	_update_progress()
	_update_character_focus(str(node.get("focus", "none")), node)

	match str(node.get("type", "line")):
		"line":
			_show_line(node)
		"choice":
			_show_choice(node)
		"end":
			_show_end(node)
		_:
			_show_fatal_error("알 수 없는 장면 형식입니다: %s" % node.get("type", ""))


func _show_line(node: Dictionary) -> void:
	_clear_choices()
	speaker_label.text = str(node.get("speaker", "내레이션"))
	next_node_id = str(node.get("next", ""))
	continue_button.visible = true
	feedback_label.text = ""
	_start_typewriter(str(node.get("text", "")))


func _show_choice(node: Dictionary) -> void:
	_clear_choices()
	next_node_id = ""
	speaker_label.text = str(node.get("speaker", "선택"))
	_start_typewriter(str(node.get("text", "")))
	continue_button.visible = false
	for option_value in node.get("options", []):
		if typeof(option_value) != TYPE_DICTIONARY:
			continue
		var option: Dictionary = option_value
		var button := Button.new()
		button.text = str(option.get("text", "선택"))
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 38)
		button.add_theme_font_size_override("font_size", 15)
		_style_button(button, true)
		button.pressed.connect(_choose_option.bind(option))
		choice_box.add_child(button)


func _choose_option(option: Dictionary) -> void:
	var effects: Dictionary = option.get("effects", {})
	GameState.apply_effects(effects)
	GameState.add_flags(Array(option.get("flags", [])))
	feedback_label.text = _describe_effects(effects)
	_play_node(str(option.get("next", "")))


func _show_end(node: Dictionary) -> void:
	_clear_choices()
	next_node_id = ""
	speaker_label.text = str(node.get("speaker", "완료"))
	_start_typewriter(str(node.get("text", "")))
	continue_button.visible = false
	feedback_label.text = "제1장 자동 저장 완료 · 다음 장은 추후 연결됩니다."

	var replay_button := Button.new()
	replay_button.text = "제1장 다시 보기"
	replay_button.custom_minimum_size = Vector2(0, 42)
	_style_button(replay_button, true)
	replay_button.pressed.connect(_start_new_chapter)
	choice_box.add_child(replay_button)


func _advance() -> void:
	if is_typing:
		_finish_typewriter()
		return
	if not next_node_id.is_empty():
		_play_node(next_node_id)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("advance_dialogue") and continue_button.visible:
		get_viewport().set_input_as_handled()
		_advance()


func _start_typewriter(text_value: String) -> void:
	current_full_text = text_value
	dialogue_text.text = text_value
	dialogue_text.visible_characters = 0
	is_typing = true
	typewriter_timer.start()


func _on_typewriter_tick() -> void:
	if not is_typing:
		return
	dialogue_text.visible_characters += 2
	if dialogue_text.visible_characters >= current_full_text.length():
		_finish_typewriter()


func _finish_typewriter() -> void:
	typewriter_timer.stop()
	dialogue_text.visible_characters = -1
	is_typing = false


func _clear_choices() -> void:
	for child in choice_box.get_children():
		choice_box.remove_child(child)
		child.queue_free()


func _update_status(new_stats: Dictionary = {}) -> void:
	var values := new_stats if not new_stats.is_empty() else GameState.stats
	status_label.text = "애정 %d  ·  신뢰 %d  ·  존중 %d  ·  서운함 %d" % [
		int(values.get("affection", 0)),
		int(values.get("trust", 0)),
		int(values.get("respect", 0)),
		int(values.get("resentment", 0)),
	]


func _update_progress() -> void:
	progress_bar.max_value = maxf(float(nodes.size()), 1.0)
	progress_bar.value = float(visited.size())


func _update_character_focus(focus: String, node: Dictionary) -> void:
	match focus:
		"minwoo":
			minwoo_card.modulate = Color(1, 1, 1, 1)
			seojeong_card.modulate = Color(0.60, 0.64, 0.64, 0.72)
		"seojeong":
			minwoo_card.modulate = Color(0.60, 0.64, 0.64, 0.72)
			seojeong_card.modulate = Color(1, 1, 1, 1)
		_:
			minwoo_card.modulate = Color(0.82, 0.84, 0.83, 0.88)
			seojeong_card.modulate = Color(0.82, 0.84, 0.83, 0.88)
	if node.has("minwoo_mood"):
		minwoo_mood.text = str(node["minwoo_mood"])
	if node.has("seojeong_mood"):
		seojeong_mood.text = str(node["seojeong_mood"])


func _describe_effects(effects: Dictionary) -> String:
	var names := {
		"affection": "애정",
		"trust": "신뢰",
		"respect": "존중",
		"resentment": "서운함",
		"minwoo_fatigue": "민우 피로",
		"seojeong_stress": "서정 스트레스",
	}
	var parts: Array[String] = []
	for key in effects.keys():
		var amount := int(effects[key])
		var sign_text := "+" if amount > 0 else ""
		parts.append("%s %s%d" % [names.get(key, str(key)), sign_text, amount])
	return " · ".join(parts)


func _show_fatal_error(message: String) -> void:
	speaker_label.text = "불러오기 오류"
	dialogue_text.text = message
	dialogue_text.visible_characters = -1
	continue_button.visible = false
	_clear_choices()


func _apply_visual_style() -> void:
	var top_style := _make_panel_style(Color("#18262bdd"), Color("#42575b"), 1, 14)
	$SafeMargin/RootVBox/TopBar.add_theme_stylebox_override("panel", top_style)

	var card_style := _make_panel_style(Color("#19272cdd"), Color("#536265"), 1, 18)
	minwoo_card.add_theme_stylebox_override("panel", card_style)
	seojeong_card.add_theme_stylebox_override("panel", card_style.duplicate())

	var dialogue_style := _make_panel_style(Color("#111b1ff2"), Color("#9c7952"), 2, 18)
	dialogue_panel.add_theme_stylebox_override("panel", dialogue_style)

	_style_button(restart_button, false)
	_style_button(load_button, false)
	_style_button(continue_button, true)
	_update_status()


func _make_panel_style(color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.22)
	style.shadow_size = 8
	return style


func _style_button(button: Button, is_primary: bool) -> void:
	var normal_color := Color("#9c6b3d") if is_primary else Color("#27383d")
	var hover_color := Color("#b27a43") if is_primary else Color("#354a50")
	var pressed_color := Color("#754b29") if is_primary else Color("#1c2a2e")
	button.add_theme_stylebox_override("normal", _make_panel_style(normal_color, Color("#c19a6b"), 1, 10))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_color, Color("#e1bd8c"), 1, 10))
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_color, Color("#9e774e"), 1, 10))
	button.add_theme_color_override("font_color", Color("#f5efe5"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)

