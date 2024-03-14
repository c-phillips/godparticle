extends Label

var current: float = 0
var last_update = Time.get_ticks_msec()

# Called when the node enters the scene tree for the first time.
func _ready():
	self.current = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.current -= delta
	if Time.get_ticks_msec() - self.last_update > 10:
		self.text = "%1.2f" % self.current
		self.last_update = Time.get_ticks_msec()
