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
	var world_camera := main.get_node_or_null("%WorldCamera") as Camera3D
	var cafe_world := main.get_node_or_null("WorldViewportContainer/WorldViewport/World3D/CafeWorld3D") as Node3D
	var selection := main.get_node_or_null("%SelectionOverlay") as ColorRect
	var choice_box := main.get_node_or_null("%CharacterChoiceBox") as HBoxContainer
	var speech_bubble := main.get_node_or_null("%SpeechBubble") as PanelContainer
	var dialogue_choice_box := main.get_node_or_null("%ChoiceBox") as VBoxContainer
	var bubble_speaker := main.get_node_or_null("%BubbleSpeaker") as Label
	var bubble_text := main.get_node_or_null("%BubbleText") as RichTextLabel
	if player == null or world_camera == null or cafe_world == null or selection == null or choice_box == null or speech_bubble == null or dialogue_choice_box == null or bubble_speaker == null or bubble_text == null:
		_fail("Selection or exploration nodes are missing")
		return
	if bubble_speaker.get_theme_font_size("font_size") > 13 or bubble_text.get_theme_font_size("normal_font_size") > 13:
		_fail("Dialogue fonts are larger than the compact type scale")
		return
	if cafe_world.get_node_or_null("BackWallCollision") as StaticBody3D == null:
		_fail("The 3D back wall/window boundary is missing its collision body")
		return
	if cafe_world.get_node_or_null("TableTopCollision") as StaticBody3D == null:
		_fail("The 3D cafe furniture is missing collision bodies")
		return
	var top_hud := main.get_node_or_null("%TopHud") as PanelContainer
	if top_hud == null or top_hud.size.y > 56.0:
		_fail("Top HUD was not reduced enough: %s" % (top_hud.size if top_hud != null else Vector2.ZERO))
		return
	player.global_position = Vector3(0.0, 0.0, -3.5)
	await physics_frame
	var window_wall_hit := player.move_and_collide(Vector3(0.0, 0.0, -1.2))
	if window_wall_hit == null or player.global_position.z < -3.9:
		_fail("Player was able to cross the 3D window/back-wall boundary")
		return
	player.global_position = Vector3(-3.15, 0.0, 2.55)

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

	player.face_toward(player.global_position + Vector3.RIGHT)
	if absf(player.rotation.y - PI * 0.5) > 0.01 or player.facing != "right":
		_fail("Player did not rotate and face toward the travel direction")
		return

	var seojeong := npc_nodes.get("yun_seojeong") as Node3D
	player.global_position = seojeong.global_position + Vector3(0.8, 0.0, 0.0)
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
	if dialogue_choice_box.get_child_count() < 2:
		_fail("Story choice buttons were not created")
		return
	var down_event := InputEventAction.new()
	down_event.action = "ui_down"
	down_event.pressed = true
	main.call("_unhandled_input", down_event)
	if int(main.get("selected_choice_index")) != 1:
		_fail("Down arrow did not move the selected answer")
		return
	var selected_answer := dialogue_choice_box.get_child(1) as Button
	if selected_answer == null or not selected_answer.text.begins_with("▶") or selected_answer.get_theme_font_size("font_size") > 11:
		_fail("Selected answer indicator or compact answer font is incorrect")
		return
	var story_nodes: Dictionary = main.get("nodes")
	var choice_node: Dictionary = story_nodes["choice_first_care"]
	var options: Array = choice_node["options"]
	var expected_next := str((options[1] as Dictionary).get("next", ""))
	var space_event := InputEventAction.new()
	space_event.action = "advance_dialogue"
	space_event.pressed = true
	main.call("_unhandled_input", space_event)
	main.call("_unhandled_input", space_event)
	if str(main.get("current_node_id")) != expected_next:
		_fail("Spacebar did not submit the highlighted answer")
		return

	main.call("_finish_conversation")
	main.call("_show_character_selection")
	main.call("_select_character", "jeong_jieun")
	await process_frame
	npc_nodes = main.get("npc_nodes")
	var doyun := npc_nodes.get("han_doyun") as Node3D
	player.global_position = doyun.global_position + Vector3(0.8, 0.0, 0.0)
	await process_frame
	if not bool(main.get("ambient_mode")):
		_fail("Non-story NPC did not start automatic dialogue")
		return
	if str(main.get("conversation_kind")) != "female_first_meeting":
		_fail("Female player did not enter the female first-meeting scenario")
		return

	var doyun_position := doyun.position
	main.call("_finish_conversation")
	player.global_position = Vector3(-5.0, 0.0, 3.4)
	main.call("_animate_npcs", 0.25)
	if doyun.position.is_equal_approx(doyun_position):
		_fail("NPC autonomous movement did not update its position")
		return

	main.call("_show_character_selection")
	main.call("_select_character", "kang_minwoo")
	await process_frame
	npc_nodes = main.get("npc_nodes")
	doyun = npc_nodes.get("han_doyun") as Node3D
	player.global_position = doyun.global_position + Vector3(0.8, 0.0, 0.0)
	await process_frame
	if str(main.get("conversation_kind")) != "peer_male":
		_fail("Same-gender male characters did not enter peer dialogue")
		return

	main.call("_finish_conversation")
	main.call("_show_character_selection")
	main.call("_select_character", "yun_seojeong")
	await process_frame
	npc_nodes = main.get("npc_nodes")
	var minwoo := npc_nodes.get("kang_minwoo") as Node3D
	player.global_position = minwoo.global_position + Vector3(0.8, 0.0, 0.0)
	await process_frame
	if str(main.get("conversation_kind")) != "female_first_meeting":
		_fail("Seojeong did not begin with the female first-meeting scenario")
		return
	if not bool(main.get("ambient_followup_story")):
		_fail("Seojeong first meeting is not linked to chapter one")
		return
	for step in range(5):
		main.call("_advance_ambient")
	if str(main.get("conversation_kind")) != "story":
		_fail("Seojeong first meeting did not continue into chapter one")
		return

	print("Exploration validation passed: 3D collisions, movement rotation, gender dialogue, NPC movement, first-meeting story")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
