extends Node

@onready var statsPanel = $"../../textParent/StatsPanel"

@export var window: Control
@export var stat = {
	"mood": 0.0,
	"hunger": 0.0,
	"sleep": 0.0,
}

func _ready() -> void:
	upd(stat)

func upd(stats: Dictionary) -> void:
	statsPanel.set_stats(stats)

func _process(_delta: float) -> void:
	pass
