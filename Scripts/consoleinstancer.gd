extends Node

var scene = preload("res://scenes/theThing.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_rapier_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:

	#i just figured out what the input signal does and im realizing how much time i wasted
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_LEFT:
				if Input.is_action_pressed("ctrl"):
					var instance = scene.instantiate()
					get_tree().current_scene.add_child(instance)
					instance.position = get_viewport().get_mouse_position()
					
