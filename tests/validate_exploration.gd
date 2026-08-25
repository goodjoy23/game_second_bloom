extends SceneTree


func _initialize() -> void:
	var packed_scene := load("res://scenes/main.tscn") as PackedScene
	if packed_scene == null:
		_fail("Main scene could not be loaded")
		return

	var main := packed_scene.instantiate()
	root.add_child(main)
	await process_frame

	var player := main.get_node_or_null("%Player") as PlayerController
	var selection := main.get_node_or_null("%SelectionOverlay") as ColorRect
	var choice_box := main.get_node_or_null("%CharacterChoiceBox") as HBoxContainer
	var speech_bubble := main.get_node_or_null("%SpeechBubble") as PanelContainer
	if player == null or selection == null or choice_box == null or speech_bubble == null:
		_fail("Selection or exploration nodes are missing")
		return

	if not selection.visible or player.movement_enabled:
		_fail("Character selection should appear before movement")
		return
	if choice_box.get_child_count() != 5:
		_fail("Expected five selectable characters")
		return

	main.call("_select_character", "kang_minwoo")
	await process_frame
	var npc_nodes: Dictionary = main.get("npc_nodes")
	if selection.visible or not player.visible or not player.movement_enabled:
		_fail("Selected character did not enter exploration mode")
		return
	if player.character_id != "kang_minwoo" or npc_nodes.size() != 4:
		_fail("Player selection or NPC roster is incorrect")
		return

	var seojeong := npc_nodes.get("yun_seojeong") as Node2D
	player.global_position = seojeong.global_position + Vector2(72.0, 0.0)
	await process_frame
	if not speech_bubble.visible or player.movement_enabled:
		_fail("Proximity did not start the speech bubble conversation")
		return
	if speech_bubble.size.x > 460.0 or speech_bubble.size.y > 320.0:
		_fail("Speech bubble is larger than the compact UI limit: %s" % speech_bubble.size)
		return

	main.call("_play_node", "choice_first_care")
	await process_frame
	if speech_bubble.size.x > 460.0 or speech_bubble.size.y > 360.0:
		_fail("Choice speech bubble is larger than the compact UI limit: %s" % speech_bubble.size)
		return

	main.call("_finish_conversation")
	main.call("_show_character_selection")
	main.call("_select_character", "jeong_jieun")
	await process_frame
	npc_nodes = main.get("npc_nodes")
	var doyun := npc_nodes.get("han_doyun") as Node2D
	player.global_position = doyun.global_position + Vector2(72.0, 0.0)
	await process_frame
	if not bool(main.get("ambient_mode")):
		_fail("Non-story NPC did not start automatic dialogue")
		return

	print("Exploration validation passed: 5 choices, 4 NPCs, proximity speech bubble")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
