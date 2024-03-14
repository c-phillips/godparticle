extends Node3D

@export var pause_timer: float
@export var buttons: Array

var previous_fov: float = 0.0
var children_noise: Array
var children_pins: Array
var children_accel: Array


# Called when the node enters the scene tree for the first time.
func _ready():
	var noise = FastNoiseLite.new()
	noise.seed = Time.get_unix_time_from_system()+69
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	self.children_noise.append(noise)
	noise = FastNoiseLite.new()
	noise.seed = Time.get_unix_time_from_system()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	self.children_noise.append(noise)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not self.visible: return
	for i in range(buttons.size()):
		var child = self.get_node(self.buttons[i])
		#if child is Node2D or child is Control: continue
		var noise_vec = Vector3(
			clamp(self.children_noise[0].get_noise_3dv(child.position), -1, 1),
			clamp(self.children_noise[1].get_noise_3dv(child.position), -1, 1),
			0
		)*2
		self.children_accel[i] += noise_vec*delta
		var diff = child.position - self.children_pins[i]
		self.children_accel[i] -= diff.length()*diff.normalized()*delta
		child.position += self.children_accel[i]*delta*0.95
		child.look_at(get_viewport().get_camera_3d().global_position)
		child.rotate_object_local(Vector3.UP, PI)
	
	
func pause():
	var camera = get_viewport().get_camera_3d()
	self.previous_fov = camera.fov
	
	self.children_pins = []
	self.children_accel = []
	for child in get_children():
		self.children_pins.append(child.position)
		self.children_accel.append(Vector3(0, 0, 0))
	var tween = self.create_tween()
	tween.tween_property(camera, "fov", 90, 0.5).set_trans(Tween.TRANS_SPRING)

func unpause(skip=false):
	var camera = get_viewport().get_camera_3d()
	if not skip:
		for btn in self.buttons:
			self.get_node(btn).hide()
		var tween = self.create_tween()
		$Countdown.current = self.pause_timer
		$Countdown.show()
		tween.tween_property(camera, "fov", self.previous_fov, self.pause_timer).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback( self.do_unpause )
	else:
		camera.fov = self.previous_fov
		self.do_unpause()

func do_unpause():
	$Countdown.hide()
	for btnpath in self.buttons:
		self.get_node(btnpath).show()
	get_tree().paused = false
	hide()
