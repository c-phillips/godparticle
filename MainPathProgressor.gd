extends PathFollow3D

@export var min_velocity: float = 175
@export var max_velocity: float = 300
@export var velocity: float = 180

var track: Path3D

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	self.track = get_parent()


func _process(delta):
	if self.progress_ratio >= 0.999:
		self.finished.emit()
		return
		
	if not $Player/PlayerBody.frozen:
		var s = $Player/PlayerBody.score
		var target_speed = clamp( s/10+self.velocity , self.min_velocity, self.max_velocity)
		var diff = self.velocity - target_speed
		if diff > 0.05:
			self.velocity += diff*0.25
		else:
			self.velocity = target_speed
	else:
		self.velocity = 0.0
	self.progress += self.velocity*delta

