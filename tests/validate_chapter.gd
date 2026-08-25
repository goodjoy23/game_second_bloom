extends SceneTree


func _initialize() -> void:
	var path := "res://data/chapter_01.json"
	if not FileAccess.file_exists(path):
		_fail("Missing chapter data: %s" % path)
		return

	var file := FileAccess.open(path, FileAccess.READ)
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_fail("Chapter JSON is invalid")
		return

	var data: Dictionary = parsed
	var ids: Dictionary = {}
	for node_value in data.get("nodes", []):
		if typeof(node_value) != TYPE_DICTIONARY:
			_fail("Every node must be a Dictionary")
			return
		var node: Dictionary = node_value
		var id := str(node.get("id", ""))
		if id.is_empty() or ids.has(id):
			_fail("Missing or duplicate node id: %s" % id)
			return
		ids[id] = true

	var start_id := str(data.get("start", ""))
	if not ids.has(start_id):
		_fail("Start node does not exist: %s" % start_id)
		return

	for node_value in data.get("nodes", []):
		var node: Dictionary = node_value
		if node.has("next") and not ids.has(str(node["next"])):
			_fail("Broken next link in %s: %s" % [node["id"], node["next"]])
			return
		for option_value in node.get("options", []):
			var option: Dictionary = option_value
			if not ids.has(str(option.get("next", ""))):
				_fail("Broken choice link in %s" % node["id"])
				return

	print("Chapter validation passed: %d nodes" % ids.size())
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)

