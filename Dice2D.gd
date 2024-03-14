class_name Dice2D extends RigidBody2D


enum views {TOP, LINEAR, HEX}
const shape_sprites = {
	views.TOP: 		preload("res://sprites/dice/dice_flat.png"),
	views.LINEAR: 	preload("res://sprites/dice/dice_linear.png"),
	views.HEX: 		preload("res://sprites/dice/dice_hex.png"),
}
const shape_sprite_scales = {
	views.TOP:		0.33,
	views.LINEAR:	0.33,
	views.HEX:		0.33
}
const shape_sprite_rotations = {
	views.TOP:		[0],
	views.LINEAR:	[0, PI],
	views.HEX:		[0, PI/3, 2*PI/3]
}

const pip_sprites = {
	0: preload("res://sprites/dice/pips/1.png"),
	1: preload("res://sprites/dice/pips/2.png"),
	2: preload("res://sprites/dice/pips/3.png"),
	3: preload("res://sprites/dice/pips/4.png"),
	4: preload("res://sprites/dice/pips/5.png"),
	5: preload("res://sprites/dice/pips/6.png")
}

@onready var col_shapes = {
	views.TOP: 		$SquareCollider,
	views.LINEAR: 	$LinearCollider,
	views.HEX: 		$HexCollider
}

var current_view = views.TOP

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var last_rotate = 0
var value: int
var stopped: bool = false

var speed_flip_scale = 1.0
var flip_idx: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self._set_sprite()
	self._set_collision_shape()


func _physics_process(delta):
	var vel = self.linear_velocity
	if vel.length() < 100:
		self.linear_velocity = Vector2(0, 0)
		self.angular_velocity = 0.0
		self._stop_rolling()
	else:
		if self.stopped:
			self.stopped = false
			$pips.hide()
			$spotlight.hide()
		self.speed_flip_scale = vel.length()/100
		var angle_to = float((int(abs(vel.angle_to(Vector2(1, 0)))*1000) % int(PI/2*1000))/1000)
		if PI/4 <= angle_to and angle_to <= 3*PI/4:
			self.current_view = views.HEX
		else:
			self.current_view = views.LINEAR
		#self.linear_velocity -= vel.normalized()*pow(vel.length(), -5)*5000.0*delta
		self.linear_velocity -= vel.normalized()*vel.length()*1.0*delta

	self._set_sprite()
	self._set_collision_shape()


func _stop_rolling():
	if not self.stopped:
		self.stopped = true
		self.value = self.rng.randi_range(0,5)
		self.current_view = views.TOP
		$pips.texture = pip_sprites[self.value]
		$pips.scale = Vector2(1, 1)*0.35
		$pips.rotation = self.rotation
		$pips.show()
		self.stopped = true
		if self.value == 5:
			$spotlight.rotation = -self.rotation
			$spotlight.modulate = Color(1, 1, 1, 0)
			var tween = get_tree().create_tween()
			tween.tween_property($spotlight, "modulate", Color(1, 1, 1, 1), 2)
			$spotlight.show()


func _set_sprite():
	$sprite.texture  = shape_sprites[self.current_view]
	$sprite.scale 	 = Vector2(1,1)*shape_sprite_scales[self.current_view]
	$sprite.rotation = self.rotation
	
	if Time.get_ticks_msec() - self.last_rotate > 200/self.speed_flip_scale:
		self.flip_idx += 1
		self.last_rotate = Time.get_ticks_msec()
	$sprite.rotation += shape_sprite_rotations[self.current_view][self.flip_idx % shape_sprite_rotations[self.current_view].size()]


func _set_collision_shape():
	for key in self.col_shapes:
		var value = self.col_shapes[key]
		value.disabled = key != self.current_view
