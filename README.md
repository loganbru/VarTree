# VarTree

**VarTree** is a custom `Tree` node that allows you to monitor and display variable values in-game in a structured format.

## Features

- Track and display any variable or expression in-game.
- Organize tracked variables into nested categories.

## Usage

### Properties

#### `update_on_process: bool`

If true, `VarTree` automatically calls `update_all()` every frame via `_process()`.  
Set to `false` to update manually.

#### `value_alignment: int`

Controls the horizontal text alignment of the value column.  
Values:
- `0` (Left)
- `1` (Center)
- `2` (Right)

### Variable Options
These are options applied to individual variables through the `mount_var` method.

| Option | Description | Example |
| --- | --- | --- |
| `bg_color : Color` | Sets a custom background color. | `{"bg_color": Color.RED}` |
| `font : Font` | Sets a custom font. | `{"font": preload("path_to_font")}` |
| `font_color : Color` | Sets a custom font color. | `{"font_color": Color.BLUE}` |
| `font_size : int` | Sets a custom font size. | `{"font_size": 12}` |
| `format_callback : Callable` | Method used to format the value to a string. | `{"format_callback": _format_vector2}` |
| `label : String` | Custom label for the variable. | `{"label": "Player Health"}` |

#### `format_callback : Callable`
The callback method should take the value as an input and return a string for display.
```gdscript
# Example formatter that displays a readable Vector2
func _format_vector2(_input : Vector2) -> String:
      return "X: %0.2f, Y: %02.f" % [_input.x, _input.y]
```

### Button Options

There are currently _no_ button options but I have plans to implement some.

### Methods

#### `mount_var(node: Node, path: String, options: Dictionary = {}) -> TreeItem`

Mounts a variable from the given `node` to the tree.
_Returns_ the `TreeItem` associated with the variable.

- `node`: The node that owns the variable.  
- `path`: The variable name including the category path.
   - If no category, then _only_ include the `variable_name`. The variable will be mounted to the root of the tree.
- `options`: A dictionary including the options for the variable. <sub>*[Variable Options](#variable-options)*</sub>

```gdscript
# Example
$VarTree.mount_var(player, "mouse_position")
$VarTree.mount_var(self, "Player/Stats/current_health", {options ...})
```

#### `mount_button(path: String, callback : Callable), options: Dictionary = {}) -> TreeItem`

Mounts a clickable button to the tree. When the button is _clicked_, the `callback` method is called.
_Returns_ the `TreeItem` associated with the button.

- `path`: Works like the path parameter from the [mount_var()](#methods) method, however, the variable_name is replaced with the text for the button label.  
- `callback`: The method called when the button is pressed.
- `options`: A dictionary including the options for the button. <sub>*[Button Options](#button-options)*</sub>

```gdscript
# Example
$VarTree.mount_button("Player/Stats/Restore Health", _heal_player, {options ...})

func _heal_player() -> void:
   # heal the player...
```

#### `update_all()`

Gets and displays the current values of all mounted variables.
```gdscript
$VarTree.update_all()
```

### Example Implementation
```gdscript
extends Node2D

# Reference to VarTree node
@onready var var_tree : VarTree = $CanvasLayer/VarTree

# Stores the seconds passed since start
var counter : float = 0.0

func _ready() -> void:
      # Mount the counter variable
      var_tree.mount_var(self, "Time Elapsed/counter", {
         "font_color" : Color.RED,
         "format_callback" : _format_float
      })

      # Mount the reset counter button
      var_tree.mount_button("Time Elapsed/Reset Counter", _reset_counter)

func _process(delta : float) -> void:
      # Update counter
      counter += delta

func _reset_counter() -> void:
      # Reset counter
      counter = 0.0

func _format_float(_input : float) -> String:
      # Return the float formatted as a string and rounded to the nearest hundredth
      return str(snappedf(_input, 0.01))

```

## Next Update
- Individual variable update targetting.
- Button Options
   - Custom button textures
   - Built in callbacks
   - Editable items to collect inputs for button callbacks.