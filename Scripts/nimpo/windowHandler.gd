extends Control

#window
# On any Control node

@export var Handle: Button
@export var Minimize: Button
@export var Exit: Button

@export var ConsoleN: Control
@export var SettingsN: Control
@export var StatN: Control
#@export var Statistics: Control
var offset = Vector2.ZERO
var dragging = false

#border numbers that i stole from somewhere
var global_top_left: Vector2 = global_position
var global_top_right: Vector2 = global_position + Vector2(size.x, 0)
var global_bottom_left: Vector2 = global_position + Vector2(0, size.y)
var global_bottom_right: Vector2 = global_position + size

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	_on_tab_switch_item_selected(0)
	pass

func _process(_delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - offset

# SIGNAL FROM HANDLE
func _downDrag() -> void:
	if gbData.devMode:
		print("dragging")
	offset = get_global_mouse_position() - global_position
	dragging = true
	move_to_front()

# SIGNAL FROM HANDLE
func _upDrag() -> void:
	dragging = false


func _hide(_t: bool) -> void:
	self.visible = false
	pass # Replace with function body.


func _on_tab_switch_item_selected(index: int) -> void:
	match index:
		0:
			ConsoleN.visible = false
			SettingsN.visible = false
			if gbData.devMode:
				print("Statistics")
		1:
			ConsoleN.visible = true
			SettingsN.visible = false
			if gbData.devMode:
				print("Console")
		2:
			ConsoleN.visible = false
			SettingsN.visible = true
			if gbData.devMode:
				print("Settings")

	pass # Replace with function body.
