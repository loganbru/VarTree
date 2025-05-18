class_name VarTree extends Tree
## A variable Tree that allows you to track variable values in-game.

## Changes the alignment of the value display cell.
@export_enum("Left:0", "Right:2", "Center:1") var value_alignment: int

## Root tree item.
var root : TreeItem = null
## Storage array for TreeItems of mounted variables. Used for updating.
var mounted_vars : Array[TreeItem] = []

func _init() -> void:
	columns = 2
	column_titles_visible = false
	set_column_title(0, "Variable")
	set_column_title(1, "Value")
	select_mode = Tree.SELECT_ROW
	hide_root = true
	
	connect("button_clicked", _on_button_clicked)
	
	if !root:
		root = create_item()
		root.set_metadata(0, {
			"item_type" : 0
		})

func _process(delta: float) -> void:
	update_all()

## Creates a category at the given path. Returns the TreeItem representing the category. [br][br]
## Can also be used to retrieve a category TreeItem but it will create the category if it doesn't exist.
func create_category(path: String) -> TreeItem:
	var path_arr = path.split("/")
	var current_item = root

	for path_item in path_arr:
		var found = false
		var child = current_item.get_first_child()
		while child:
			var meta : Dictionary = child.get_metadata(0)
			if meta.item_type == 0:
				if meta.category_name == path_item:
					current_item = child
					found = true
					break
			child = child.get_next()

		if not found:
			# Create the category item
			var new_cat = create_item(current_item)
			new_cat.set_text(0, path_item)
			new_cat.set_metadata(0, {
				"item_type" : 0,
				"category_name" : path_item
			})
			current_item = new_cat

	return current_item

## Mounts a variable at the given path. [br][br]
## The path string should be the categories followed by the variable name: [code]Player/Stats/current_health[/code] [br][br]
## OR, just the variable name if you want it to live on the root category: [code]current_health[/code]
func mount_var(node : Node, path : String, options : Dictionary = {}) -> TreeItem:
	var path_arr : Array = path.split("/")
	var parent : TreeItem = root
	var var_name : String = path

	if path_arr.size() > 1:
		var_name = path_arr[-1]
		var category_path_arr = path_arr
		category_path_arr.remove_at(path_arr.size() - 1)
		parent = create_category("/".join(category_path_arr))
	
	var tree_item : TreeItem = parent.create_child()
	tree_item.set_text(0, var_name)
	tree_item.set_tooltip_text(0, "Variable: %s, Node: %s" % [var_name, node.name])
	tree_item.set_text(1, "unknown")
	
	tree_item.set_text_alignment(1, value_alignment)
	
	tree_item.set_metadata(0, {
		"item_type" : 1,
		"node" : node,
		"var_name" : var_name,
		"options" : options
	})
	
	apply_options(tree_item)
	
	mounted_vars.append(tree_item)
	return tree_item

## Mounts a clickable button to the tree with the given callback. When the button is clicked, the callback will be called. [br][br]
## The path works the same as in [method VarTree.mount_var] except the variable name should be replaced with the button label. [br][br]
## [code]Player/Stats/Reset Health[/code] OR [code]Reset Health[/code]
func mount_button(path : String, callback : Callable, options : Dictionary = {}) -> TreeItem:
	var path_arr : Array = path.split("/")
	var parent : TreeItem = root
	var button_name : String = path
	
	if path_arr.size() > 1:
		button_name = path_arr[-1]
		var category_path_arr = path_arr
		category_path_arr.remove_at(path_arr.size() - 1)
		parent = create_category("/".join(category_path_arr))
	
	var tree_item : TreeItem = parent.create_child()
	tree_item.set_text(0, button_name)
	tree_item.add_button(1, preload("res://addons/var_tree/button.svg"))
	tree_item.set_metadata(0, {
		"item_type" : 2,
		"callback" : callback,
		"options" : options
	})
	
	return tree_item

## Updates the values for all mounted variables. [br][br]
## TODO: Add optional param [code]path[/code] in order to target specific variables for updating.
func update_all() -> void:
	for tree_item : TreeItem in mounted_vars:
		var meta : Dictionary = tree_item.get_metadata(0)
		var val = meta.node.get(meta.var_name)
		var formatted : String = str(val)
		
		if meta.options.has("format_callback"):
			formatted = meta.options.format_callback.call(val)
		
		tree_item.set_text(1, str(formatted))
		tree_item.set_tooltip_text(1, "Type: %s" % type_string(typeof(val)))

## Applys options to the given TreeItem like font_size, color, bg_color, etc.
func apply_options(tree_item : TreeItem) -> void:
	var options : Dictionary = tree_item.get_metadata(0).options
	
	if options.keys().size() == 0:
		return
	
	if options.has("label"):
		tree_item.set_text(0, options.label)
	
	if options.has("bg_color"):
		tree_item.set_custom_bg_color(0, options.bg_color)
		tree_item.set_custom_bg_color(1, options.bg_color)
	
	if options.has("font_color"):
		tree_item.set_custom_color(0, options.font_color)
		tree_item.set_custom_color(1, options.font_color)
	
	if options.has("font_size"):
		tree_item.set_custom_font_size(0, options.font_size)
		tree_item.set_custom_font_size(1, options.font_size)
	
	if options.has("font"):
		tree_item.set_custom_font(0, options.font)
		tree_item.set_custom_font(1, options.font)

func _on_button_clicked(item: TreeItem, column: int, id: int, mouse_button_index: int) -> void:
	item.get_metadata(0).callback.call()
