extends Area3D

var contact_particles: GPUParticles3D

var moving: bool = false
var entered_time: int

var ring: MeshInstance3D
var glass: MeshInstance3D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.contact_particles = get_node("ContactParticles")
	self.body_entered.connect(self._contact)
	
	self.ring = get_node("Ring")
	self.glass = get_node("Glass")

func _process(delta):
	if self.moving:
		self.ring.position -= 500*delta*self.ring.basis.y
	
		if Time.get_ticks_msec() - self.entered_time > 75:
			self.queue_free()

func _contact(body):
	self.contact_particles.emitting = true
	remove_child(self.glass)
	self.moving = true
	self.entered_time = Time.get_ticks_msec()
