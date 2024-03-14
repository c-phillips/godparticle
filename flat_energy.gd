extends Node2D

var velocity = Vector2(0, 0)
var target = null
var aspect: float = 0.0
var screen_rect: Vector2

var tween: Tween
var last_trail_time: int = 0
@export var trail_update_interval: int = 10
@export var trail_length: int = 10
@onready var trail = $Trail

# Called when the node enters the scene tree for the first time.
func _ready():
	self.screen_rect = get_viewport().get_visible_rect().size
	self.aspect = self.screen_rect.x/self.screen_rect.y


func _physics_process(delta):
	if self.target != null:
		if not $EnergyBall/Splash.emitting:
			self.velocity = Vector2(randfn(0, 5), randfn(0, 5))*1500
			$EnergyBall/Splash.emitting = true
		var tpos = get_viewport().get_camera_3d().unproject_position(self.target.global_position+self.target.velocity*delta)
		var diff = tpos - $EnergyBall.global_position
		self.velocity += diff.normalized()*pow(diff.length(), 2)*delta
		if self.velocity.length() > 0:
			self.velocity -= 0.4*self.velocity
		$EnergyBall.global_position += self.velocity*delta


func _process(delta):
	if self.target != null:
		var t_ms = Time.get_ticks_msec()
		if t_ms > self.last_trail_time+self.trail_update_interval:
			if self.trail.get_point_count() > self.trail_length:
				self.trail.remove_point(0)
			self.trail.add_point($EnergyBall.global_position)
			self.trail.width = $EnergyBall.scale.x*25
			self.last_trail_time = t_ms
