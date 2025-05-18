@tool
extends EditorPlugin

const node_script := preload("res://addons/var_tree/var_tree.gd")
const icon := preload("res://addons/var_tree/icon.svg")

func _enter_tree() -> void:
	# Initialization of the plugin goes here.
	add_custom_type("VarTree", "Tree", node_script, icon)

func _exit_tree() -> void:
	# Clean-up of the plugin goes here.
	remove_custom_type("VarTree")
