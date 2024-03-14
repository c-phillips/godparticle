extends Path3D

@export var num_bloops: int = 500

var bloops: Array
var sep: float
var pr: float = 0

var bloop_obj = preload("res://bloop.tscn")

var gate_resource = preload("res://energy_nodule.tscn")
var test_obs = preload("res://test_obs.tscn")
var ring = preload("res://circle.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	var length = self.curve.get_baked_length()
	self.sep = length/self.num_bloops
	
	for i in range(self.num_bloops):
		var submesh = bloop_obj.instantiate()
		var sample_point = self.sep*i
		var point = self.curve.sample_baked(sample_point)
		var point_transform = self.curve.sample_baked_with_rotation(sample_point)
		submesh.translate(point)
		submesh.basis = point_transform.basis
		submesh.rotate_object_local(Vector3(1, 0, 0), PI/2)
		add_child(submesh)
		bloops.append(submesh)
	
	self.generate_stuff()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	self.pr += 0.17*delta
	if self.pr > 1.0:
		self.pr = self.pr-1.0
	for i in range(len(self.bloops)):
		var bloop = self.bloops[i]
		var sample_point = self.curve.get_baked_length()*self.pr+self.sep*i
		if sample_point > self.curve.get_baked_length():
			sample_point -= self.curve.get_baked_length()
		var point = self.curve.sample_baked(sample_point)
		var xform = self.curve.sample_baked_with_rotation(sample_point)
		bloop.global_position = point
		bloop.basis = xform.basis
		bloop.rotate_object_local(Vector3(1, 0, 0), PI/2)



func generate_stuff():
	var angle_noise = FastNoiseLite.new()
	var scale_noise = FastNoiseLite.new()
	var random = RandomNumberGenerator.new()
	
	var offset = 800
	var length = self.curve.get_baked_length() - offset
	var sep = 15
	var num_rings = floor(length/sep)
	for i in range(num_rings):
		var packet = gate_resource.instantiate()
		var point = self.curve.sample_baked(sep*(i+1)+offset)
		var point_transform = self.curve.sample_baked_with_rotation(sep*(i+1)+offset)
		var an = angle_noise.get_noise_3dv(point/3)
		var sn = (scale_noise.get_noise_3dv(point/3)+1.5)/2  # TODO: see if this is more fun than a constant offset
		packet.global_position = (point+point_transform.basis.y.rotated(point_transform.basis.z, an*PI*2)*sn*10)
		packet.basis = point_transform.basis
		packet.rotate_object_local(Vector3(1, 0, 0), PI/2)
		#get_tree().root.get_child(0).add_child(packet)
		add_child(packet)
	
	offset = 800
	length = self.curve.get_baked_length() - offset
	sep = 50
	num_rings = floor(length/sep)
	for i in range(num_rings):
		var ring = ring.instantiate()
		var point = self.curve.sample_baked(sep*(i+1)+offset)
		var point_transform = self.curve.sample_baked_with_rotation(sep*(i+1)+offset)
		ring.global_position = point
		ring.basis = point_transform.basis
		ring.rotate_object_local(Vector3(1, 0, 0), PI/2)
		#get_tree().root.get_child(0).add_child(ring)
		add_child(ring)
		
	offset = 1000
	length = self.curve.get_baked_length() - offset
	sep = 400
	num_rings = floor(length/sep)
	for i in range(num_rings):
		var obs = test_obs.instantiate()
		obs.process_mode = Node.PROCESS_MODE_INHERIT
		obs.allow_collision = true
		var point = self.curve.sample_baked(sep*(i+1)+offset)
		var point_transform = self.curve.sample_baked_with_rotation(sep*(i+1)+offset)
		var an = random.randf()
		#obs.global_position = point
		obs.global_position = (point+point_transform.basis.y.rotated(point_transform.basis.z, random.randf()*PI*2)*(random.randf()+0.5)*2)
		obs.rotate_object_local(Vector3(0, 0, -1), random.randf()*PI*2)
		#get_tree().root.get_child(0).add_child(obs)
		add_child(obs)
	
	offset = 500
	length = self.curve.get_baked_length() - offset
	sep = 20
	num_rings = floor(length/sep)
	for i in range(num_rings):
		var decor_obs = test_obs.instantiate()
		var point = self.curve.sample_baked(sep*(i+1)+offset)
		var point_transform = self.curve.sample_baked_with_rotation(sep*(i+1)+offset)
		decor_obs.global_position = (point+point_transform.basis.y.rotated(point_transform.basis.z, random.randf()*PI*2)*(random.randf()+0.5)*50)
		decor_obs.basis = point_transform.basis
		decor_obs.rotate_object_local(
			Vector3(
				random.randf(),
				random.randf(),
				random.randf()
			).normalized(),
			random.randf()*PI/2
		)
		#get_tree().root.get_child(0).add_child(decor_obs)
		add_child(decor_obs)
