class_name RomanceGameState
extends Node

signal state_changed(stats: Dictionary)

const SAVE_PATH := "user://chapter_01_save.json"
const DEFAULT_STATS := {
	"affection": 0,
	"trust": 0,
	"respect": 0,
	"resentment": 0,
	"minwoo_fatigue": 35,
	"seojeong_stress": 48,
}

var stats: Dictionary = DEFAULT_STATS.duplicate(true)
var flags: Dictionary = {}


func reset() -> void:
	stats = DEFAULT_STATS.duplicate(true)
	flags.clear()
	state_changed.emit(stats.duplicate(true))


func apply_effects(effects: Dictionary) -> void:
	for key in effects.keys():
		if not stats.has(key):
			continue
		stats[key] = clampi(int(stats[key]) + int(effects[key]), 0, 100)
	state_changed.emit(stats.duplicate(true))


func add_flags(new_flags: Array) -> void:
	for flag in new_flags:
		flags[str(flag)] = true


func has_flag(flag: String) -> bool:
	return bool(flags.get(flag, false))


func save_progress(node_id: String) -> bool:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false

	var payload := {
		"node_id": node_id,
		"stats": stats,
		"flags": flags,
	}
	file.store_string(JSON.stringify(payload, "\t"))
	return true


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


func load_progress() -> Dictionary:
	if not has_save():
		return {}

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}

	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}

	var loaded: Dictionary = parsed
	var loaded_stats: Dictionary = loaded.get("stats", {})
	stats = DEFAULT_STATS.duplicate(true)
	for key in loaded_stats.keys():
		if stats.has(key):
			stats[key] = clampi(int(loaded_stats[key]), 0, 100)
	flags = Dictionary(loaded.get("flags", {})).duplicate(true)
	state_changed.emit(stats.duplicate(true))
	return loaded


func delete_save() -> void:
	if has_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))

