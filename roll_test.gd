extends Control

@export var num_dice: int = 2
@export var throw_scale: float = 1.0
@export var min_throw_time: float = 1.5

var dice_obj = preload("res://Dice2D.tscn")
var dice: Array = []
var start_roll: float = 0.0

var finished_flag: bool = false
signal finished(value: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	var dims = get_viewport_rect().size
	$BottomWall.position += Vector2(0, dims.y)
	$RightWall.position += Vector2(dims.x, 0)
	
	$RollButton.pressed.connect(roll)


func roll(progress=0.0):
	if self.dice.size() > 0:
		for die in self.dice: die.queue_free()
		self.dice = []
	self.num_dice = max(floor(7*(1-progress)), 1)
	$RollButton.disabled = true
	$RollButton.text = "Rolling..."
	var rng = RandomNumberGenerator.new()
	for i in range(self.num_dice):
		var die = dice_obj.instantiate()
		die.position = Vector2(rng.randi_range(10, 500), rng.randi_range(10, 500))
		die.apply_central_force(Vector2(rng.randf_range(0, 1), rng.randf_range(0, 1))*throw_scale)
		self.dice.append(die)
		add_child(die)
	self.start_roll = Time.get_ticks_msec()
	$RollMusic.play()

func finish_roll(max_value: int):
	if not self.finished_flag:
		self.finished_flag = true
		$RollButton.disabled = false
		$RollButton.text = "Roll Again"
		$RollMusic.stop()
		if max_value >= 5:
			$RollSuccess.play()
			$RollSuccess.finished.connect(func():
				self.finished.emit(max_value)
				self.queue_free()
			)
		else:
			$RollFail.play()
			var timer = get_tree().create_timer(0.5)
			timer.timeout.connect(func():
				self.finished.emit(max_value)
				self.queue_free()
			)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var num_stopped = 0
	var max_value = 0
	for die in self.dice:
		num_stopped += int(die.stopped)
		if die.value > max_value:
			max_value = die.value
	if num_stopped == self.num_dice and Time.get_ticks_msec() - self.start_roll >= self.min_throw_time*1000:
		self.finish_roll(max_value)
