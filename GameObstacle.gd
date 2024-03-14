class_name GameObstacle extends Area3D

#@export var refpath: Path3D
var refpoint: Vector3 = Vector3(0, 0, 0)
var refdir: Vector3
var start_pos: Vector3

var wooshed = false

@export var allow_collision: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.start_pos = self.global_position
	self.refpoint = get_tree().root.get_child(0).get_node("LevelBase/Track").curve.get_closest_point(self.global_position)
	self.refdir = (self.global_position - self.refpoint).normalized()
	
	self.set_meta("game_obstacle", true)
	self.body_entered.connect(body_enter)
	if not self.allow_collision:
		for child in get_children():
			if child is CollisionShape3D or child is CollisionPolygon3D:
				remove_child(child)
		#remove_child($WooshSound)

func body_enter(body):
	print(body)
	if body.has_method("player_collide"):
		body.player_collide(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _physics_process(delta):
	var player = get_tree().root.get_child(0).get_node("LevelBase/Track/Shuttle/Player/PlayerBody")
	var diff = player.global_position - self.global_position
	var distance = diff.length()
	if distance < 1000:
		if distance < 50 and not self.wooshed:
			$WooshSound.play()
			self.wooshed = true
		var scale_factor = smoothstep(0, 500, 500-distance)*5+1
		self.scale = Vector3(1,1,1)*scale_factor
		if scale_factor > 1:
			self.global_position = self.start_pos + self.refdir*scale_factor
