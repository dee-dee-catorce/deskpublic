extends Node

# the thing that lets you drag around the objects in the scene, and also handles the outline when hovering
@export var outlineWidth: int

@export var _dect: Area2D
@export var mainrigid: RigidBody2D
@export var root: Node2D
var _foundDect := true
var _hovering := false
var _currLine := 0.0
var _dragging := false
var _dragger: StaticBody2D
var _joint: DampedSpringJoint2D


func _ready() -> void:
	pass


func _process(_delta: float) -> void:
	if not _foundDect or not _dect:
		return

	var mousePos := _dect.get_global_mouse_position()

	if _dragging and not Input.is_action_pressed("click"):
		_stopDrag()

		if not _isMouseOver(mousePos):
			_setHover(false)

	if _dragging and _dragger:
		_dragger.global_position = mousePos

	if not _dragging:
		var nowHovering := _isMouseOver(mousePos)

		if nowHovering and not _hovering:
			_onEnter()
		elif not nowHovering and _hovering:
			_onExit()

	if _hovering \
	and not _dragging \
	and Input.is_action_just_pressed("click") \
	and Input.is_action_pressed("shift"):
		_startDrag(mousePos)

	var targetLine := float(outlineWidth) if (_hovering or _dragging) else 0.0
	_currLine = lerp(_currLine, targetLine, 0.5)
	# sprite.material.set_shader_parameter("thickness", _currLine)


func _isMouseOver(mousePos: Vector2) -> bool:
	var space := _dect.get_world_2d().direct_space_state
	var query := PhysicsPointQueryParameters2D.new()

	query.position = mousePos
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var results := space.intersect_point(query)

	return results.any(func(r): return r["collider"] == _dect)


func _startDrag(mousePos: Vector2) -> void:
	if not mainrigid:
		push_warning("mainrigid is not assigned!")
		return
	root.tempRagdoll()
	_dragging = true

	_dragger = StaticBody2D.new()
	_joint = DampedSpringJoint2D.new()

	_dragger.add_child(_joint)
	get_tree().current_scene.add_child(_dragger)

	await get_tree().process_frame

	if not _dragging or not is_instance_valid(mainrigid):
		return

	_dragger.global_position = mousePos

	# Connect the mouse body to the rigidbody being dragged
	_joint.node_a = _joint.get_path_to(_dragger)
	_joint.node_b = _joint.get_path_to(mainrigid)

	_joint.stiffness = 2000.0
	_joint.damping = 105.0
	_joint.length = 0.0

	if gbData.devMode:
		print("drag started")


func _stopDrag() -> void:
	_dragging = false
	root.Stand()
	if _dragger:
		_dragger.queue_free()
		_dragger = null
		_joint = null

	if gbData.devMode:
		print("drag stopped")


func _onEnter() -> void:
	print("entered")
	_setHover(true)


func _onExit() -> void:
	print("exit")
	_setHover(false)


func _setHover(value: bool) -> void:
	if value == _hovering:
		return

	_hovering = value

	if gbData.devMode:
		print("hovering", value)

	if value:
		GlobalVariable.clickZoneSum += 1
	else:
		GlobalVariable.clickZoneSum -= 1

	if gbData.devMode:
		print("clickZoneSum: ", GlobalVariable.clickZoneSum)

	TransparentWindow.SetClickThrough(GlobalVariable.clickZoneSum <= 0)