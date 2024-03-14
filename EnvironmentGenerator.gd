extends Node3D

@export var track: Path3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var gate_resource = preload("res://gate.tscn")
	
	var angle_noise = FastNoiseLite.new()
	var scale_noise = FastNoiseLite.new()
	var random = RandomNumberGenerator.new()
	
	for i in range(100):
		var submesh = MeshInstance3D.new()
		submesh.mesh = BoxMesh.new()
		var random_position = Vector3(
			random.randf_range(-100, 100),
			random.randf_range(-100, 100),
			random.randf_range(0, 100),
		)
		var random_rotation = Vector3(
			random.randf_range(-1, 1),
			random.randf_range(-1, 1),
			random.randf_range(-1, 1),
		)
		submesh.translate(random_position)
		submesh.rotate(random_rotation.normalized(), random.randf_range(0, 2*PI))
		add_child(submesh)
	
	var length = self.track.curve.get_baked_length()
	var sep = 75
	var num_rings = floor(length/sep)
	for i in range(num_rings):
		var gate = gate_resource.instantiate()
		var point = self.track.curve.sample_baked(sep*(i+1))
		var point_transform = self.track.curve.sample_baked_with_rotation(sep*(i+1))
		var an = angle_noise.get_noise_3dv(point)
		var sn = scale_noise.get_noise_3dv(point)
		gate.global_position = (point+point_transform.basis.y.rotated(point_transform.basis.z, an*PI*2)*sn*10)
		gate.basis = point_transform.basis
		gate.rotate_object_local(Vector3(1, 0, 0), PI/2)
		gate.body_entered.connect()
		add_child(gate)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
