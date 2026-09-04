@tool
@icon("res://addons/soupik/icons/icon_look_at.png")
class_name SoupLookAt
extends SoupMod

## "Souperior" modification for Skeleton2D; Points bone at itself or a target.


## Offset angle from target.
@export_range(-180, 180, 0.1, "radians_as_degrees") var angle_offset: float = 0.0

## Enable clamping of the resulting bone angle.
@export var use_angle_constraints: bool = false

## Minimum allowed bone angle (local, relative to bone's rest angle).
@export_range(-180, 180, 0.1, "radians_as_degrees") var min_angle: float = -180.0

## Maximum allowed bone angle (local, relative to bone's rest angle).
@export_range(-180, 180, 0.1, "radians_as_degrees") var max_angle: float = 180.0

## The to-be-modified bone node.
@export var bone_node: Bone2D:
	set(value):
		bone_node = value
		if Engine.is_editor_hint():
			update_configuration_warnings()

## Optional target node; otherwise targets the IK node itself.
@export var target_node: Node2D


func _get_configuration_warnings():
	var warn_msg: Array[String] = []
	if !bone_node:
		warn_msg.append("Bone not set!")
	return warn_msg


func _process_loop(delta) -> void:
	if !(
			bone_node
			and enable_check()
		):
		return
	scale_orient = sign(bone_node.global_transform.determinant())
	handle_look_at(delta)


## [not intended for access]
## Handles the modification.
func handle_look_at(delta) -> void:
	var target_vector = global_position - bone_node.global_position
	if target_node:
		target_vector = target_node.global_position - bone_node.global_position
	var target_rotation = target_vector.angle() \
			- (bone_node.get_bone_angle() - angle_offset) # no mirroring calc here (this is a global angle, and flipping it turned the head away from the target)

	if use_angle_constraints:
		target_rotation = clamp_target_rotation(target_rotation)

	var _strength = get_inherited_strength()
	if bone_node is SoupBone2D:
		bone_node.set_target_rotation(lerp_angle(bone_node.angle_to_global(bone_node.target_rotation), target_rotation, _strength))
	else:
		bone_node.global_rotation = lerp_angle(bone_node.global_rotation, target_rotation, _strength)


## [not intended for access]
## Clamps a global target rotation to [min_angle, max_angle] measured
## relative to the bone's rest angle, in the bone's local (parent) space.
func clamp_target_rotation(global_target_rotation: float) -> float:
	# Convert global target rotation into the bone's local/parent space,
	# accounting for mirroring the same way handle_look_at builds it.
	var parent_rotation = bone_node.get_parent().global_rotation if bone_node.get_parent() else 0.0
	var rest_angle = bone_node.get_bone_angle()

	# Local rotation relative to parent, undo scale/mirroring.
	var local_rotation = (global_target_rotation - parent_rotation) * scale_orient

	# Offset relative to the bone's rest pose.
	var relative_angle = wrapf(local_rotation - rest_angle, -PI, PI)

	var clamped_relative = clamp(relative_angle, min_angle, max_angle)

	var clamped_local_rotation = clamped_relative + rest_angle
	var clamped_global_rotation = clamped_local_rotation * scale_orient + parent_rotation

	return clamped_global_rotation


func _draw_gizmo() -> void:
	if target_node: draw_set_transform(to_local(target_node.global_position), target_node.global_rotation + global_rotation)
	draw_strength(strength_gizmo_scale)
	draw_target()
	if use_angle_constraints:
		draw_angle_constraints()


## [not intended for access]
## Draws an arc/wedge showing the allowed angle range, in bone-local space.
func draw_angle_constraints() -> void:
	if !bone_node:
		return
	var parent_rotation = bone_node.get_parent().global_rotation if bone_node.get_parent() else 0.0
	var rest_angle = bone_node.get_bone_angle()
	var base_global_rotation = rest_angle * scale_orient + parent_rotation

	draw_set_transform(to_local(bone_node.global_position), base_global_rotation - global_rotation)

	var radius = strength_gizmo_scale * 2.0
	var color = Color(1.0, 0.8, 0.2, 0.5)
	var point_count = 16
	var points: PackedVector2Array = [Vector2.ZERO]
	for i in range(point_count + 1):
		var t = min_angle + (max_angle - min_angle) * float(i) / float(point_count)
		points.append(Vector2(cos(t), sin(t)) * radius)
	draw_polygon(points, [color])

	draw_line(Vector2.ZERO, Vector2(cos(min_angle), sin(min_angle)) * radius, Color.RED, 1.0)
	draw_line(Vector2.ZERO, Vector2(cos(max_angle), sin(max_angle)) * radius, Color.RED, 1.0)