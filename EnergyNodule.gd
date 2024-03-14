extends Area3D

var submesh: MeshInstance3D
var target: Node3D = null

var velocity: Vector3 = Vector3(0, 0, 0)

var emitter: GPUParticles3D = null
var captured: bool = false
var timeout: int

@onready var flatenergy: Node2D = $FlatEnergy

# Called when the node enters the scene tree for the first time.
func _ready():
	self.submesh = get_node("EnergyMesh")
	self.emitter = get_node("EnergyParticles")


#func attract(target):
	#self.target = target
	#self.timeout = Time.get_ticks_msec()

func collect(target):
	self.target = target
	self.timeout = Time.get_ticks_msec()
	#self.emitter.emitting = true
	remove_child(self.submesh)
	remove_child(get_node("Floopies"))
	var camera = get_viewport().get_camera_3d()
	self.flatenergy.get_node("EnergyBall").global_position = camera.unproject_position(self.global_position)
	self.flatenergy.visible = true
	self.flatenergy.target = target
	self.captured = true
	#$FlatEnergy/MagnetSound.play()
	$BloopSound.play()
	return 1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate_object_local(self.submesh.basis.x, 2*PI*delta)
	
	if self.target != null:
		if Time.get_ticks_msec() - self.timeout > 500:
			self.queue_free()
