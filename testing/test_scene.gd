extends Node2D

@onready var var_tree : VarTree = $CanvasLayer/VarTree
@onready var player : CharacterBody2D = $Player

func _ready() -> void:
	var_tree.mount_var(player, "Player/Movement/current_speed", {
		"format_callback" : _format_player_speed
	})
	var_tree.mount_var(player, "Player/Movement/position", {
		"format_callback" : _format_vector2
	})
	var_tree.mount_var(player, "Player/Stats/current_health", {
		"font_color" : Color.YELLOW,
		"format_callback" : func (_input : float) -> String:
			return str(snappedf(_input, 0.01))
	})

func _format_player_speed(_input : float) -> String:
	return "%0.2f / %0.2f" % [_input, player.max_speed]

func _format_vector2(_input : Vector2) -> String:
	return "X: %0.2f Y: %0.2f" % [_input.x, _input.y]
