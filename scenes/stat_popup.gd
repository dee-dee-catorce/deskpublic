extends Control

var original_offset_left: float
var original_offset_right: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	original_offset_left = offset_left
	original_offset_right = offset_right
	set_stats({})


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	ensure_visibility()
	pass


# Updates components with given stats
func set_stats(stats : Dictionary):
	$ItemList/StatsNameLabel.text = "#%d" % int(stats.get("id", 0))
	$ItemList/StatsContainer/MoodContainer/MoodProgressBar.value = stats.get("mood", 0.0)
	$ItemList/StatsContainer/HungerContainer/HungerProgressBar.value = stats.get("hunger", 0.0)
	$ItemList/StatsContainer/SleepContainer/SleepProgressBar.value = stats.get("sleep", 0.0)


# Ensures that the stats control is always fully visible,
# even if sawian stands at the edge of the screen.
func ensure_visibility():
	offset_left = original_offset_left
	offset_right = original_offset_right
	
	if !visible:
		return

	var viewport_rect := get_viewport_rect()
	var rect := get_global_rect()

	var shift := 0.0

	if rect.end.x > viewport_rect.end.x:
		shift = -(rect.end.x - viewport_rect.end.x)

	elif rect.position.x < viewport_rect.position.x:
		shift = viewport_rect.position.x - rect.position.x

	offset_left += shift
	offset_right += shift
