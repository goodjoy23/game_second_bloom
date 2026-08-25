extends Control

const CHAPTER_PATH := "res://data/chapter_01.json"
const AUTO_TALK_DISTANCE := 1.25
const TALK_RELEASE_DISTANCE := 1.75
const PLAYER_START := Vector3(-3.15, 0.0, 2.55)

const CHARACTER_ORDER := [
	"kang_minwoo",
	"yun_seojeong",
	"jeong_jieun",
	"han_doyun",
	"bae_suhyeon",
]

const CHARACTERS := {
	"kang_minwoo": {
		"name": "강민우",
		"age": 46,
		"gender": "male",
		"gender_label": "남성",
		"role": "목공방 운영",
		"mood": "말보다 손이 먼저",
		"npc_position": Vector3(-3.15, 0.0, 2.55),
		"greeting": "비가 더 거세지네요. 미끄러우니 천천히 걸어요.",
		"reply": "괜찮으면, 제가 도울 일이 있는지 먼저 물어볼게요.",
		"response": "서두르지 않아도 됩니다. 여기서는 천천히 이야기해요.",
	},
	"yun_seojeong": {
		"name": "윤서정",
		"age": 44,
		"gender": "female",
		"gender_label": "여성",
		"role": "번역가 · 카페 매니저",
		"mood": "창밖의 비를 듣는 중",
		"npc_position": Vector3(3.10, 0.0, -2.15),
		"greeting": "어서 오세요. 비 냄새가 책장 안쪽까지 들어왔네요.",
		"reply": "괜찮다는 말보다, 오늘은 솔직하게 이야기해 볼게요.",
		"response": "따뜻한 차를 내올게요. 잠깐 숨을 고르고 가세요.",
	},
	"jeong_jieun": {
		"name": "정지은",
		"age": 42,
		"gender": "female",
		"gender_label": "여성",
		"role": "베이커리 대표",
		"mood": "새벽 일을 마친 오후",
		"npc_position": Vector3(-4.10, 0.0, 0.55),
		"greeting": "빵은 식기 전에 먹어야 해요. 고민도 너무 오래 묵히면 딱딱해지고요.",
		"reply": "오늘은 농담 뒤로 숨지 않고, 하고 싶은 말을 해볼래요.",
		"response": "좋아요. 대신 서로의 일정부터 솔직하게 맞춰봐요.",
	},
	"han_doyun": {
		"name": "한도윤",
		"age": 48,
		"gender": "male",
		"gender_label": "남성",
		"role": "출판사 편집팀장",
		"mood": "일정표를 잠시 덮음",
		"npc_position": Vector3(4.65, 0.0, 1.65),
		"greeting": "계획에 없던 오후도 가끔은 필요하더군요.",
		"reply": "정답을 정리하기보다, 오늘은 상대의 말을 끝까지 들어볼게요.",
		"response": "그게 좋겠습니다. 해결보다 이해가 먼저인 날도 있으니까요.",
	},
	"bae_suhyeon": {
		"name": "배수현",
		"age": 47,
		"gender": "female",
		"gender_label": "여성",
		"role": "인테리어 실장",
		"mood": "공간의 결을 살피는 중",
		"npc_position": Vector3(1.05, 0.0, 2.80),
		"greeting": "이 카페는 빈자리를 잘 남겨뒀네요. 사람 사이도 그래야 편하죠.",
		"reply": "가까워지는 것과 서로의 자리를 지키는 건 함께 가능하다고 믿어요.",
		"response": "그 말을 기억할게요. 거리를 거절로 오해하지 않도록요.",
	},
}

const NAME_TO_ID := {
	"강민우": "kang_minwoo",
	"윤서정": "yun_seojeong",
	"정지은": "jeong_jieun",
	"한도윤": "han_doyun",
	"배수현": "bae_suhyeon",
}

@onready var top_hud: PanelContainer = %TopHud
@onready var chapter_label: Label = %ChapterLabel
@onready var objective_label: Label = %ObjectiveLabel
@onready var status_label: Label = %StatusLabel
@onready var restart_button: Button = %RestartButton
@onready var load_button: Button = %LoadButton
@onready var character_button: Button = %CharacterButton
@onready var world_camera: Camera3D = %WorldCamera
@onready var npc_layer: Node3D = %NpcLayer
@onready var player: PlayerController = %Player
@onready var player_sprite: Sprite3D = %PlayerSprite
@onready var player_name: Label3D = %PlayerName
@onready var player_mood: Label3D = %PlayerMood
@onready var speech_bubble: PanelContainer = %SpeechBubble
@onready var bubble_tail: Polygon2D = %BubbleTail
@onready var bubble_speaker: Label = %BubbleSpeaker
@onready var auto_label: Label = %AutoLabel
@onready var bubble_text: RichTextLabel = %BubbleText
@onready var feedback_label: Label = %FeedbackLabel
@onready var choice_box: VBoxContainer = %ChoiceBox
@onready var bubble_hint: Label = %BubbleHint
@onready var continue_button: Button = %ContinueButton
@onready var typewriter_timer: Timer = %TypewriterTimer
@onready var auto_reply_timer: Timer = %AutoReplyTimer
@onready var selection_overlay: ColorRect = %SelectionOverlay
@onready var selection_panel: PanelContainer = %SelectionPanel
@onready var character_choice_box: HBoxContainer = %CharacterChoiceBox

var chapter: Dictionary = {}
var nodes: Dictionary = {}
var npc_nodes: Dictionary = {}
var selected_character_id := ""
var active_npc_id := ""
var bubble_target_id := ""
var proximity_latch := ""
var current_node_id := ""
var next_node_id := ""
var current_full_text := ""
var is_typing := false
var dialogue_active := false
var ambient_mode := false
var ambient_followup_story := false
var conversation_kind := ""
var ambient_lines: Array[Dictionary] = []
var ambient_index := 0
var visited: Dictionary = {}
var selected_choice_index := -1


func _ready() -> void:
	_apply_visual_style()
	_connect_signals()
	_load_chapter_data()
	_build_character_choices()
	player.visible = false
	player.set_movement_enabled(false)
	_show_character_selection()


func _process(delta: float) -> void:
	_animate_npcs(delta)
	if selection_overlay.visible:
		return
	if dialogue_active:
		_position_speech_bubble()
		return
	_update_proximity_conversations()


func _connect_signals() -> void:
	restart_button.pressed.connect(_restart_story)
	load_button.pressed.connect(_continue_saved_chapter)
	character_button.pressed.connect(_show_character_selection)
	continue_button.pressed.connect(_advance)
	typewriter_timer.timeout.connect(_on_typewriter_tick)
	auto_reply_timer.timeout.connect(_advance_ambient)
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
	return not nodes.is_empty()


func _build_character_choices() -> void:
	for child in character_choice_box.get_children():
		child.queue_free()

	for character_id in CHARACTER_ORDER:
		var data: Dictionary = CHARACTERS[character_id]
		var gender_color := _gender_color(str(data["gender"]))
		var card := PanelContainer.new()
		card.custom_minimum_size = Vector2(205.0, 245.0)
		card.add_theme_stylebox_override("panel", _make_panel_style(Color("#17262bdd"), gender_color, 2, 14))

		var margin := MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 12)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 12)
		card.add_child(margin)

		var stack := VBoxContainer.new()
		stack.add_theme_constant_override("separation", 6)
		margin.add_child(stack)

		var portrait := TextureRect.new()
		portrait.custom_minimum_size = Vector2(0.0, 108.0)
		portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		portrait.texture = load("res://assets/characters/%s/frames/down.png" % character_id)
		portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stack.add_child(portrait)

		var name_label := Label.new()
		name_label.text = "%s · %d세" % [data["name"], data["age"]]
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.add_theme_color_override("font_color", Color("#f3e6cf"))
		name_label.add_theme_font_size_override("font_size", 16)
		stack.add_child(name_label)

		var gender_label := Label.new()
		gender_label.text = "%s 캐릭터" % data["gender_label"]
		gender_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		gender_label.add_theme_color_override("font_color", gender_color)
		gender_label.add_theme_font_size_override("font_size", 11)
		stack.add_child(gender_label)

		var role_label := Label.new()
		role_label.text = str(data["role"])
		role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		role_label.add_theme_color_override("font_color", Color("#9fb0ad"))
		role_label.add_theme_font_size_override("font_size", 11)
		stack.add_child(role_label)

		var select_button := Button.new()
		select_button.text = "이 인물로 시작"
		select_button.custom_minimum_size = Vector2(0.0, 34.0)
		_style_button(select_button, true)
		select_button.pressed.connect(_select_character.bind(character_id))
		stack.add_child(select_button)
		character_choice_box.add_child(card)


func _show_character_selection() -> void:
	_finish_typewriter()
	auto_reply_timer.stop()
	dialogue_active = false
	ambient_mode = false
	speech_bubble.visible = false
	bubble_tail.visible = false
	player.set_movement_enabled(false)
	selection_overlay.visible = true
	objective_label.text = "플레이할 캐릭터를 선택하세요."


func _select_character(character_id: String) -> void:
	selected_character_id = character_id
	var data: Dictionary = CHARACTERS[character_id]
	player.configure_character(character_id)
	player.global_position = PLAYER_START
	player.visible = true
	player_name.text = "%s %s · 나" % [_gender_marker(str(data["gender"])), data["name"]]
	player_mood.text = str(data["mood"])
	player_name.modulate = _gender_color(str(data["gender"])).lightened(0.18)
	_spawn_npcs()
	selection_overlay.visible = false
	proximity_latch = ""
	active_npc_id = ""
	player.set_movement_enabled(true)
	chapter_label.text = "북카페 오후 · %s의 시점" % data["name"]
	objective_label.text = "방향키로 움직여 다른 인물에게 가까이 가보세요."
	var has_story := not _canonical_partner().is_empty()
	restart_button.visible = has_story
	load_button.visible = has_story and GameState.has_save()
	_update_status()


func _spawn_npcs() -> void:
	for child in npc_layer.get_children():
		child.queue_free()
	npc_nodes.clear()

	var spawn_index := 0
	for character_id in CHARACTER_ORDER:
		if character_id == selected_character_id:
			continue
		var data: Dictionary = CHARACTERS[character_id]
		var npc := Node3D.new()
		npc.name = "NPC_%s" % character_id
		npc.position = data["npc_position"]
		npc.set_meta("character_id", character_id)
		npc.set_meta("anchor_position", data["npc_position"])
		npc.set_meta("wander_phase", float(spawn_index) * 1.71)
		npc.set_meta("facing", "down")
		npc_layer.add_child(npc)

		var sprite := Sprite3D.new()
		sprite.name = "Sprite"
		sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		sprite.position = Vector3(0.0, 0.96, 0.0)
		sprite.pixel_size = 0.03
		sprite.shaded = true
		sprite.texture = load("res://assets/characters/%s/frames/down.png" % character_id)
		npc.add_child(sprite)

		var name_label := Label3D.new()
		name_label.name = "Tag"
		name_label.text = "%s %s\n%s" % [
			_gender_marker(str(data["gender"])),
			data["name"],
			data["mood"],
		]
		name_label.position = Vector3(0.0, 1.72, 0.0)
		name_label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		name_label.no_depth_test = true
		name_label.font_size = 27
		name_label.outline_size = 9
		name_label.pixel_size = 0.006
		name_label.modulate = _gender_color(str(data["gender"])).lightened(0.18)
		name_label.outline_modulate = Color("#172024")
		npc.add_child(name_label)
		npc_nodes[character_id] = npc
		spawn_index += 1


func _update_proximity_conversations() -> void:
	var nearest_id := ""
	var nearest_distance := INF
	for character_id in npc_nodes:
		var npc := npc_nodes[character_id] as Node3D
		var distance := player.global_position.distance_to(npc.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_id = character_id

	if not proximity_latch.is_empty():
		var latched_npc := npc_nodes.get(proximity_latch) as Node3D
		if latched_npc == null or player.global_position.distance_to(latched_npc.global_position) > TALK_RELEASE_DISTANCE:
			proximity_latch = ""

	if nearest_id.is_empty():
		return
	if nearest_distance <= AUTO_TALK_DISTANCE and proximity_latch != nearest_id:
		proximity_latch = nearest_id
		_begin_proximity_conversation(nearest_id)


func _begin_proximity_conversation(npc_id: String) -> void:
	active_npc_id = npc_id
	dialogue_active = true
	player.set_movement_enabled(false)
	var npc := npc_nodes[npc_id] as Node3D
	player.face_toward(npc.global_position)
	_face_npc_toward(npc_id, player.global_position)
	speech_bubble.visible = true
	bubble_tail.visible = true
	speech_bubble.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(speech_bubble, "modulate:a", 1.0, 0.14)

	var player_gender := str(CHARACTERS[selected_character_id]["gender"])
	var npc_gender := str(CHARACTERS[npc_id]["gender"])
	if npc_id == _canonical_partner() and player_gender == "male":
		ambient_mode = false
		auto_label.text = "이야기"
		bubble_hint.text = "스페이스바로 이어가기"
		_start_new_chapter()
	else:
		_start_gender_conversation(npc_id, player_gender, npc_gender)


func _start_gender_conversation(npc_id: String, player_gender: String, npc_gender: String) -> void:
	ambient_mode = true
	ambient_index = 0
	ambient_followup_story = false
	var npc_data: Dictionary = CHARACTERS[npc_id]
	var player_data: Dictionary = CHARACTERS[selected_character_id]

	if player_gender == npc_gender:
		conversation_kind = "peer_%s" % player_gender
		auto_label.text = "동료 대화"
		if player_gender == "male":
			ambient_lines = [
				{"speaker_id": npc_id, "speaker": npc_data["name"], "text": "일 얘기는 잠시 접어두죠. 요즘은 어떻게 지냅니까?"},
				{"speaker_id": selected_character_id, "speaker": player_data["name"], "text": "버티는 것과 괜찮은 건 다르더군요. 오늘은 좀 쉬어가려고요."},
				{"speaker_id": npc_id, "speaker": npc_data["name"], "text": "잘 생각했습니다. 말없이 앉아 있어도 편한 자리가 필요하니까요."},
			]
		else:
			ambient_lines = [
				{"speaker_id": npc_id, "speaker": npc_data["name"], "text": "오늘만큼은 일과 돌봄 얘기 말고, 당신 얘기를 듣고 싶어요."},
				{"speaker_id": selected_character_id, "speaker": player_data["name"], "text": "좋아요. 누군가의 역할이 아닌 내 마음부터 이야기해 볼게요."},
				{"speaker_id": npc_id, "speaker": npc_data["name"], "text": "그럼 천천히요. 서로의 시간을 재촉하지 않기로 해요."},
			]
	elif player_gender == "female":
		conversation_kind = "female_first_meeting"
		auto_label.text = "첫 만남 · 여성 시점"
		ambient_followup_story = selected_character_id == "yun_seojeong" and npc_id == "kang_minwoo"
		ambient_lines = [
			{
				"speaker_id": selected_character_id,
				"speaker": player_data["name"],
				"text": "처음 보는 얼굴이다. 먼저 말을 걸어도 괜찮을까, 잠시 망설였다.",
			},
			{"speaker_id": npc_id, "speaker": npc_data["name"], "text": npc_data["greeting"]},
			{"speaker_id": selected_character_id, "speaker": player_data["name"], "text": player_data["reply"]},
			{"speaker_id": npc_id, "speaker": npc_data["name"], "text": npc_data["response"]},
			{
				"speaker_id": selected_character_id,
				"speaker": player_data["name"],
				"text": "짧은 인사였지만, 이 사람을 조금 더 알고 싶다는 생각이 들었다.",
			},
		]
	else:
		conversation_kind = "male_first_meeting"
		auto_label.text = "첫 만남 · 남성 시점"
		ambient_lines = [
			{"speaker_id": npc_id, "speaker": npc_data["name"], "text": npc_data["greeting"]},
			{
				"speaker_id": selected_character_id,
				"speaker": player_data["name"],
				"text": "반갑습니다. 제가 먼저 답을 정하지 않고, 천천히 당신 이야기를 듣고 싶습니다.",
			},
			{"speaker_id": npc_id, "speaker": npc_data["name"], "text": npc_data["response"]},
		]

	bubble_hint.text = "잠시 후 자동으로 이어집니다"
	continue_button.visible = false
	_clear_choices()
	_show_ambient_line()


func _show_ambient_line() -> void:
	if ambient_index >= ambient_lines.size():
		if ambient_followup_story:
			ambient_mode = false
			ambient_followup_story = false
			auto_label.text = "제1장 · 첫 만남"
			bubble_hint.text = "스페이스바로 이어가기"
			continue_button.visible = true
			_start_new_chapter()
		else:
			_finish_conversation()
		return
	var line: Dictionary = ambient_lines[ambient_index]
	feedback_label.text = ""
	_show_bubble_line(str(line["speaker"]), str(line["text"]), str(line["speaker_id"]))
	auto_reply_timer.start(2.8)


func _advance_ambient() -> void:
	if not dialogue_active or not ambient_mode:
		return
	ambient_index += 1
	_show_ambient_line()


func _canonical_partner() -> String:
	if selected_character_id == "kang_minwoo":
		return "yun_seojeong"
	if selected_character_id == "yun_seojeong":
		return "kang_minwoo"
	return ""


func _restart_story() -> void:
	var partner := _canonical_partner()
	if partner.is_empty() or not npc_nodes.has(partner):
		return
	if not dialogue_active:
		_begin_proximity_conversation(partner)
	else:
		ambient_mode = false
		_start_new_chapter()


func _start_new_chapter() -> void:
	conversation_kind = "story"
	GameState.reset()
	visited.clear()
	feedback_label.text = ""
	_play_node(str(chapter.get("start", "")))


func _continue_saved_chapter() -> void:
	var partner := _canonical_partner()
	if partner.is_empty() or not npc_nodes.has(partner):
		return
	if not dialogue_active:
		active_npc_id = partner
		dialogue_active = true
		player.set_movement_enabled(false)
		speech_bubble.visible = true
		bubble_tail.visible = true
	ambient_mode = false
	auto_label.text = "이어보기"
	bubble_hint.text = "스페이스바로 이어가기"
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
	_update_character_focus(str(node.get("focus", "none")), node)
	match str(node.get("type", "line")):
		"line":
			_show_line(node)
		"choice":
			_show_choice(node)
		"end":
			_show_end(node)
		_:
			_show_fatal_error("알 수 없는 장면 형식입니다.")


func _show_line(node: Dictionary) -> void:
	_clear_choices()
	next_node_id = str(node.get("next", ""))
	continue_button.visible = true
	bubble_hint.text = "스페이스바로 이어가기"
	feedback_label.text = ""
	var speaker := str(node.get("speaker", "내레이션"))
	_show_bubble_line(speaker, str(node.get("text", "")), _speaker_character_id(speaker))


func _show_choice(node: Dictionary) -> void:
	_clear_choices()
	next_node_id = ""
	continue_button.visible = false
	bubble_hint.text = "↑↓ 선택 · 스페이스바로 전달"
	var speaker := str(node.get("speaker", "선택"))
	_show_bubble_line(speaker, str(node.get("text", "")), _speaker_character_id(speaker))
	for option_value in node.get("options", []):
		if typeof(option_value) != TYPE_DICTIONARY:
			continue
		var option: Dictionary = option_value
		var button := Button.new()
		var option_text := str(option.get("text", "선택"))
		button.text = option_text
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0.0, 30.0)
		button.add_theme_font_size_override("font_size", 11)
		button.pressed.connect(_choose_option.bind(option))
		choice_box.add_child(button)
		_register_choice_button(button, option_text)
	_select_choice_index(0)
	call_deferred("_position_speech_bubble")


func _choose_option(option: Dictionary) -> void:
	var effects: Dictionary = option.get("effects", {})
	GameState.apply_effects(effects)
	GameState.add_flags(Array(option.get("flags", [])))
	feedback_label.text = _describe_effects(effects)
	_play_node(str(option.get("next", "")))


func _show_end(node: Dictionary) -> void:
	_clear_choices()
	next_node_id = ""
	continue_button.visible = false
	var speaker := str(node.get("speaker", "완료"))
	_show_bubble_line(speaker, str(node.get("text", "")), active_npc_id)
	feedback_label.text = "자동 저장 완료"
	bubble_hint.text = "↑↓ 선택 · 스페이스바로 결정"

	var explore_button := Button.new()
	explore_button.text = "대화를 마치고 둘러보기"
	explore_button.custom_minimum_size = Vector2(0.0, 30.0)
	explore_button.add_theme_font_size_override("font_size", 11)
	explore_button.pressed.connect(_finish_conversation)
	choice_box.add_child(explore_button)
	_register_choice_button(explore_button, explore_button.text)

	var replay_button := Button.new()
	replay_button.text = "이 장면 다시 보기"
	replay_button.custom_minimum_size = Vector2(0.0, 29.0)
	replay_button.add_theme_font_size_override("font_size", 11)
	replay_button.pressed.connect(_start_new_chapter)
	choice_box.add_child(replay_button)
	_register_choice_button(replay_button, replay_button.text)
	_select_choice_index(0)


func _show_bubble_line(speaker: String, text_value: String, speaker_id: String) -> void:
	if CHARACTERS.has(speaker_id):
		var speaker_gender := str(CHARACTERS[speaker_id]["gender"])
		bubble_speaker.text = "%s %s" % [_gender_marker(speaker_gender), speaker]
		bubble_speaker.add_theme_color_override("font_color", _gender_color(speaker_gender).darkened(0.28))
	else:
		bubble_speaker.text = speaker
		bubble_speaker.add_theme_color_override("font_color", Color("#59402b"))
	bubble_target_id = speaker_id if not speaker_id.is_empty() else active_npc_id
	speech_bubble.size = Vector2(410.0, 140.0)
	_start_typewriter(text_value)
	call_deferred("_position_speech_bubble")


func _position_speech_bubble() -> void:
	if not speech_bubble.visible:
		return
	var target_position := player.global_position + Vector3(0.0, 1.58, 0.0)
	if bubble_target_id != selected_character_id and npc_nodes.has(bubble_target_id):
		target_position = (npc_nodes[bubble_target_id] as Node3D).global_position + Vector3(0.0, 1.58, 0.0)
	var screen_position := world_camera.unproject_position(target_position)

	var bubble_size := speech_bubble.size
	var desired := screen_position + Vector2(-bubble_size.x * 0.5, -bubble_size.y - 42.0)
	desired.x = clampf(desired.x, 24.0, size.x - bubble_size.x - 24.0)
	desired.y = clampf(desired.y, 72.0, size.y - bubble_size.y - 34.0)
	speech_bubble.position = desired
	bubble_tail.position = Vector2(
		clampf(screen_position.x, desired.x + 28.0, desired.x + bubble_size.x - 28.0),
		desired.y + bubble_size.y - 1.0
	)


func _finish_conversation() -> void:
	auto_reply_timer.stop()
	_finish_typewriter()
	_clear_choices()
	dialogue_active = false
	ambient_mode = false
	speech_bubble.visible = false
	bubble_tail.visible = false
	player.set_movement_enabled(true)
	_reset_character_emphasis()
	objective_label.text = "조금 멀어졌다가 다시 가까워지면 새로운 대화가 시작됩니다."


func _advance() -> void:
	if ambient_mode:
		auto_reply_timer.stop()
		_advance_ambient()
		return
	if is_typing:
		_finish_typewriter()
		return
	if not next_node_id.is_empty():
		_play_node(next_node_id)


func _unhandled_input(event: InputEvent) -> void:
	if selection_overlay.visible or not dialogue_active:
		return
	if choice_box.get_child_count() > 0:
		if event.is_action_pressed("ui_up"):
			get_viewport().set_input_as_handled()
			_move_choice_selection(-1)
			return
		if event.is_action_pressed("ui_down"):
			get_viewport().set_input_as_handled()
			_move_choice_selection(1)
			return
		if event.is_action_pressed("advance_dialogue"):
			get_viewport().set_input_as_handled()
			if is_typing:
				_finish_typewriter()
			else:
				_activate_selected_choice()
			return
	if event.is_action_pressed("advance_dialogue"):
		get_viewport().set_input_as_handled()
		_advance()


func _start_typewriter(text_value: String) -> void:
	current_full_text = text_value
	bubble_text.text = text_value
	bubble_text.visible_characters = 0
	is_typing = true
	typewriter_timer.start()


func _on_typewriter_tick() -> void:
	if not is_typing:
		return
	bubble_text.visible_characters += 2
	if bubble_text.visible_characters >= current_full_text.length():
		_finish_typewriter()


func _finish_typewriter() -> void:
	typewriter_timer.stop()
	bubble_text.visible_characters = -1
	is_typing = false


func _clear_choices() -> void:
	selected_choice_index = -1
	for child in choice_box.get_children():
		choice_box.remove_child(child)
		child.queue_free()


func _register_choice_button(button: Button, base_text: String) -> void:
	button.focus_mode = Control.FOCUS_NONE
	button.set_meta("choice_text", base_text)
	var button_index := choice_box.get_child_count() - 1
	button.mouse_entered.connect(_select_choice_index.bind(button_index))


func _move_choice_selection(direction: int) -> void:
	var choice_count := choice_box.get_child_count()
	if choice_count == 0:
		return
	var next_index := wrapi(selected_choice_index + direction, 0, choice_count)
	_select_choice_index(next_index)


func _select_choice_index(index: int) -> void:
	var choice_count := choice_box.get_child_count()
	if choice_count == 0:
		selected_choice_index = -1
		return
	selected_choice_index = clampi(index, 0, choice_count - 1)
	for button_index in range(choice_count):
		var button := choice_box.get_child(button_index) as Button
		if button == null:
			continue
		var is_selected := button_index == selected_choice_index
		var base_text := str(button.get_meta("choice_text", button.text))
		button.text = ("▶  " if is_selected else "    ") + base_text
		_style_choice_button(button, is_selected)


func _activate_selected_choice() -> void:
	if selected_choice_index < 0 or selected_choice_index >= choice_box.get_child_count():
		return
	var button := choice_box.get_child(selected_choice_index) as Button
	if button != null and not button.disabled:
		button.pressed.emit()


func _speaker_character_id(speaker: String) -> String:
	return str(NAME_TO_ID.get(speaker, ""))


func _gender_marker(gender: String) -> String:
	return "[남]" if gender == "male" else "[여]"


func _gender_color(gender: String) -> Color:
	return Color("#6f9eb5") if gender == "male" else Color("#c98b9f")


func _face_npc_toward(npc_id: String, target_position: Vector3) -> void:
	var npc := npc_nodes.get(npc_id) as Node3D
	if npc == null:
		return
	var direction := target_position - npc.global_position
	direction.y = 0.0
	var facing := "down"
	if absf(direction.x) > absf(direction.z):
		facing = "right" if direction.x > 0.0 else "left"
	else:
		facing = "down" if direction.z > 0.0 else "up"
	npc.rotation.y = atan2(direction.x, direction.z)
	_set_npc_facing(npc_id, facing)


func _set_npc_facing(npc_id: String, facing: String) -> void:
	var npc := npc_nodes.get(npc_id) as Node3D
	if npc == null or str(npc.get_meta("facing", "")) == facing:
		return
	npc.set_meta("facing", facing)
	var sprite := npc.get_node("Sprite") as Sprite3D
	sprite.texture = load("res://assets/characters/%s/frames/%s.png" % [npc_id, facing])


func _animate_npcs(delta: float) -> void:
	var now := Time.get_ticks_msec() * 0.001
	var index := 0
	for character_id in npc_nodes:
		var npc := npc_nodes[character_id] as Node3D
		var sprite := npc.get_node("Sprite") as Sprite3D
		if not (dialogue_active and character_id == active_npc_id):
			var anchor: Vector3 = npc.get_meta("anchor_position")
			var phase := float(npc.get_meta("wander_phase", 0.0))
			var radius_x := 0.16 + float(index % 3) * 0.055
			var radius_z := 0.10 + float(index % 2) * 0.045
			var desired := anchor + Vector3(
				sin(now * 0.34 + phase) * radius_x,
				0.0,
				cos(now * 0.27 + phase) * radius_z
			)
			var previous := npc.position
			npc.position = npc.position.lerp(desired, clampf(delta * 1.8, 0.0, 1.0))
			var motion := npc.position - previous
			if motion.length_squared() > 0.0000004:
				npc.rotation.y = lerp_angle(npc.rotation.y, atan2(motion.x, motion.z), clampf(delta * 8.0, 0.0, 1.0))
				if absf(motion.x) > absf(motion.z):
					_set_npc_facing(str(character_id), "right" if motion.x > 0.0 else "left")
				else:
					_set_npc_facing(str(character_id), "down" if motion.z > 0.0 else "up")
		sprite.position.y = 0.96 + sin(now * 2.1 + float(index) * 1.3) * 0.025
		index += 1


func _update_character_focus(focus: String, node: Dictionary) -> void:
	var focus_id := ""
	if focus == "minwoo":
		focus_id = "kang_minwoo"
	elif focus == "seojeong":
		focus_id = "yun_seojeong"
	_reset_character_emphasis()
	if not focus_id.is_empty():
		if focus_id == selected_character_id:
			player_sprite.modulate = Color.WHITE
			player_name.modulate = Color("#fff2cf")
		elif npc_nodes.has(focus_id):
			var npc := npc_nodes[focus_id] as Node3D
			(npc.get_node("Sprite") as Sprite3D).modulate = Color.WHITE
			(npc.get_node("Tag") as Label3D).modulate = Color("#fff2cf")
	if node.has("minwoo_mood") and selected_character_id == "kang_minwoo":
		player_mood.text = str(node["minwoo_mood"])
	if node.has("seojeong_mood") and selected_character_id == "yun_seojeong":
		player_mood.text = str(node["seojeong_mood"])


func _reset_character_emphasis() -> void:
	player_sprite.modulate = Color.WHITE
	if not selected_character_id.is_empty():
		player_name.modulate = _gender_color(str(CHARACTERS[selected_character_id]["gender"])).lightened(0.18)
	for character_id in npc_nodes:
		var npc := npc_nodes[character_id] as Node3D
		(npc.get_node("Sprite") as Sprite3D).modulate = Color.WHITE
		(npc.get_node("Tag") as Label3D).modulate = _gender_color(str(CHARACTERS[character_id]["gender"])).lightened(0.18)


func _update_status(new_stats: Dictionary = {}) -> void:
	var values := new_stats if not new_stats.is_empty() else GameState.stats
	status_label.text = "애정 %d · 신뢰 %d · 존중 %d" % [
		int(values.get("affection", 0)),
		int(values.get("trust", 0)),
		int(values.get("respect", 0)),
	]


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
	dialogue_active = true
	speech_bubble.visible = true
	bubble_tail.visible = true
	auto_label.text = "오류"
	continue_button.visible = false
	_clear_choices()
	_show_bubble_line("불러오기 오류", message, selected_character_id)


func _apply_visual_style() -> void:
	top_hud.add_theme_stylebox_override("panel", _make_panel_style(Color("#132126e8"), Color("#52666a"), 1, 14))
	speech_bubble.add_theme_stylebox_override("panel", _make_panel_style(Color("#f3ecdcfa"), Color("#b98a58"), 2, 18))
	selection_panel.add_theme_stylebox_override("panel", _make_panel_style(Color("#101b1fe8"), Color("#8b7155"), 1, 20))
	_style_button(restart_button, false)
	_style_button(load_button, false)
	_style_button(character_button, false)
	_style_button(continue_button, true)
	continue_button.add_theme_font_size_override("font_size", 11)
	_update_status()


func _make_panel_style(color: Color, border_color: Color, border_width: int, radius: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = border_color
	style.set_border_width_all(border_width)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.25)
	style.shadow_size = 8
	return style


func _style_button(button: Button, is_primary: bool) -> void:
	var normal_color := Color("#9c6b3d") if is_primary else Color("#27383d")
	var hover_color := Color("#b27a43") if is_primary else Color("#354a50")
	var pressed_color := Color("#754b29") if is_primary else Color("#1c2a2e")
	button.add_theme_stylebox_override("normal", _make_panel_style(normal_color, Color("#c19a6b"), 1, 9))
	button.add_theme_stylebox_override("hover", _make_panel_style(hover_color, Color("#e1bd8c"), 1, 9))
	button.add_theme_stylebox_override("pressed", _make_panel_style(pressed_color, Color("#9e774e"), 1, 9))
	button.add_theme_color_override("font_color", Color("#f5efe5"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)


func _style_choice_button(button: Button, is_selected: bool) -> void:
	var normal_color := Color("#9a693c") if is_selected else Color("#5d4b3c")
	var border_color := Color("#f0c58b") if is_selected else Color("#9b7c5e")
	var border_width := 2 if is_selected else 1
	button.add_theme_stylebox_override("normal", _make_panel_style(normal_color, border_color, border_width, 8))
	button.add_theme_stylebox_override("hover", _make_panel_style(Color("#ad7745"), Color("#f1cf9e"), 2, 8))
	button.add_theme_stylebox_override("pressed", _make_panel_style(Color("#754b29"), Color("#c99c69"), 2, 8))
	button.add_theme_color_override("font_color", Color("#fff7e9") if is_selected else Color("#e2d7ca"))
	button.add_theme_color_override("font_hover_color", Color.WHITE)
