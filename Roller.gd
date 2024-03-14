extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$RollArena.finished.connect(present)


func roll(progress):
	$RollMusic.play()
	#$Label.text = "rolling..."
	#var rng = RandomNumberGenerator.new()
	#var result = rng.randi_range(1, 6)
	var timer = get_tree().create_timer(1)
	timer.timeout.connect(func():
		$RollArena.roll()
	)


func present(result):
	#$Label.text = "%s" % result
	print(result)
	var timer = get_tree().create_timer(1)
	timer.timeout.connect(get_parent()._handle_roll_result.bind(result >= 5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
