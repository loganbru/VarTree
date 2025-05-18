extends Node2D

@onready var var_tree : VarTree = $CanvasLayer/VarTree

var seconds : float = 0.0
var minutes : int = 0

func _ready() -> void:
	var_tree.mount_var(self, "Time Elapsed/seconds", {
		"label" : "Seconds",
		"format_callback" : _format_float
	})
	var_tree.mount_var(self, "Time Elapsed/minutes")

func _process(delta: float) -> void:
	seconds += delta
	if seconds >= 60.0:
		seconds = 0.0
		minutes += 1

func _format_float(_input : float) -> String:
	return str(snappedf(_input, 0.01))
