## Minimal EditorPlugin for Tategaki Lite.
##
## TategakiLabelLite declares `class_name` and Godot picks that up
## project-wide, so it is usable even with this plugin disabled. This plugin
## exists so the addon shows up in Project Settings > Plugins, and to
## register a custom icon for TategakiLabelLite in the "Create Node" dialog.
@tool
extends EditorPlugin

const TATEGAKI_LITE_LABEL_ICON := "res://addons/tategaki_lite/icon.svg"


func _enter_tree() -> void:
	# On the very first --import of a fresh project the .svg has no import
	# cache yet; load() would error, so fall back to null (default icon)
	# until the next editor start re-imports it.
	var icon: Texture2D = load(TATEGAKI_LITE_LABEL_ICON) if ResourceLoader.exists(TATEGAKI_LITE_LABEL_ICON) else null
	add_custom_type(
		"TategakiLabelLite",
		"Control",
		preload("tategaki_label_lite.gd"),
		icon
	)


func _exit_tree() -> void:
	remove_custom_type("TategakiLabelLite")
