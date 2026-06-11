extends Area2D

func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			get_viewport().set_input_as_handled()
			if gbData.data.save["mood"] >= -50 and gbData.data.save["trust"] >= 30:
				GlobalVariable.petf(true)
				GlobalVariable.raisemoodF(2.5)
			else:
				GlobalVariable.petf(false)
