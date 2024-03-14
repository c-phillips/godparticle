extends Camera3D

@export var look_point: int = 20
var track: Path3D
var shuttle: PathFollow3D

# Called when the node enters the scene tree for the first time.
func _ready():
	self.shuttle = get_parent_node_3d().shuttle
	self.track = get_parent_node_3d().track


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#var current_progress = self.shuttle.progress_ratio*self.track.curve.get_baked_length()
	#var track_position = self.track.curve.sample_baked(current_progress)
	#var up_vec = self.track.curve.sample_baked_up_vector(current_progress)
	#var point = self.track.curve.sample_baked(current_progress+10)
	#look_at(point)
