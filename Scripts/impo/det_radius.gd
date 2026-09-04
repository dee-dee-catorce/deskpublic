extends Node

var inRadius = {
	#object containing itself and its properties
}

var expiesInRadius = {
	#expie root node -> {interest, behavior, body}
}

var mousePriority = 5

func _ready() -> void:
	pass

#recoded to work with properties class

func _on_dect_body_entered(body: Node2D) -> void:
	var propsNode = body.get_node_or_null("properties")
	if propsNode:
		inRadius[body] = propsNode.propertyTable.duplicate()
		return

	var expieRoot = body.get_parent().get_parent()
	if expieRoot == get_parent().get_parent():
		return
	var behavior = expieRoot.get_node_or_null("behavior")
	if behavior:
		expiesInRadius[expieRoot] = {
			"interest": 8,
			"behavior": behavior,
			"body": body,
		}


func _on_dect_body_exited(body: Node2D) -> void:
	if inRadius.has(body):
		inRadius.erase(body)

	var expieRoot = body.get_parent().get_parent()
	if expiesInRadius.has(expieRoot):
		expiesInRadius.erase(expieRoot)
