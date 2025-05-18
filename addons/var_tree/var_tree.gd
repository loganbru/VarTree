class_name VarTree extends Tree

var root : TreeItem = null
var mounted_vars : Array[TreeItem] = []

func _init() -> void:
	columns = 2
	column_titles_visible = true
	select_mode = Tree.SELECT_ROW
	hide_root = true
	set_column_title(0, "Var")
	set_column_title(1, "Value")
	
	if !root:
		root = create_item()
		root.set_metadata(0, {
			"item_type" : 0
		})

func _process(delta: float) -> void:
	update_all()

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
	tree_item.set_text(1, "unknown")
	tree_item.set_metadata(0, {
		"item_type" : 1,
		"node" : node,
		"var_name" : var_name,
		"options" : options
	})
	
	mounted_vars.append(tree_item)
	return tree_item

func update_all() -> void:
	for tree_item : TreeItem in mounted_vars:
		var meta : Dictionary = tree_item.get_metadata(0)
		var val = meta.node.get(meta.var_name)
		var formatted : String = str(val)
		
		tree_item.set_text(1, str(formatted))
