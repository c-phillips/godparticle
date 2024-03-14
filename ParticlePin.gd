class_name Player extends Node3D

@export var track: Path3D
@export var shuttle: PathFollow3D

var character: CharacterBody3D

@export var start_timeout: float = 2500
var playing = false
var waiting = true
var start_time: float
var runtime: float = 0.0

var twurnt = false

# Called when the node enters the scene tree for the first time.
func _ready():
	self.shuttle = get_parent_node_3d()
	self.track = self.shuttle.get_parent_node_3d()
	self.character = get_node("PlayerBody")
	
	# TODO: control this with the start button
	self.start_time = Time.get_ticks_msec()


func start_play():
	self.start_time = Time.get_ticks_msec()
	self.waiting = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.waiting: return
	if not self.playing:
		if not self.twurnt:
			self.twurnt = true
			var tween = get_tree().create_tween().set_parallel(true)
			#var current = get_tree().root.get_child(0).get_node("LevelBase/Hand").global_position
			var current = self.global_basis.z
			current.z *= -2000
			current += self.global_position
			tween.tween_method(look_at.bind(basis.y), current, self.track.curve.sample_baked(800), 2.1).set_trans(Tween.TRANS_ELASTIC)#.set_delay(0.5)
			tween.tween_property(get_viewport().get_camera_3d(), "fov", 75, 1.5).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)#.set_delay(0.5)
			tween.tween_callback(func():
				get_tree().create_timer(2.5).timeout.connect(func():
					get_tree().root.get_child(0).get_node("LevelBase/Hand").hide()
				)
			)
		if $PlayerBody.frozen and Time.get_ticks_msec() - self.start_time > 250:
			$PlayerBody.frozen = false
			$PlayerBody/PlayerGlow.show()
			$PlayerBody/ParticleMesh.show()
		if Time.get_ticks_msec() > self.start_time + self.start_timeout:
			self.playing = true
			$PlayerBody.starting = false
			$PlayerCamera/PlayMenu.show()
			$PlayerCamera/PlayMenu/Timer.text = "%7.2f" % 0.0
			$PlayerBody/Collector.show()
			self.start_time = Time.get_ticks_msec()
	else:
		var current_progress = self.shuttle.progress_ratio*self.track.curve.get_baked_length()
		var track_position = self.track.curve.sample_baked(current_progress)
		var rvec = self.track.curve.sample_baked_with_rotation(current_progress, false, true)
		look_at(self.track.curve.sample_baked(current_progress+100))#, rvec.basis.y)
		
		$PlayerCamera/PlayMenu/CatThing/Cat.update_score(self.character.score)
		self.runtime = (Time.get_ticks_msec()-self.start_time)/1000.0
		$PlayerCamera/PlayMenu/Timer.text = "%7.2f" % self.runtime
