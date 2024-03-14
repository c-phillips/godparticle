extends Button3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var camera = get_viewport().get_camera_3d()
	look_at(camera.global_position)
	rotate_object_local(self.basis.y, PI)
	super._ready()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
