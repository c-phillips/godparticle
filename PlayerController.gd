extends CharacterBody3D

enum ABILITIES {NONE, SPACE, TIME, MASS, ENTANGLE}
var ability_mode = ABILITIES.NONE

@export var initial_acceleration: Vector3
@export var camera_lookpoint: float = 20.0

var starting = true

var frozen = true

var acceleration = Vector3(0, 0, 0)
var track: Path3D
var shuttle: PathFollow3D

var collector: Area3D
var attractor: Area3D

var score: int = 100
var last_score_bloop: int = 0

var pulling: bool = false

var invincible: bool = false

var collision_camera_position

var ability_bar

signal collided(collision_body)

# Called when the node enters the scene tree for the first time.
func _ready():
	self.velocity = Vector3(0, 0, 0)
	self.acceleration = initial_acceleration
	
	self.shuttle = get_parent_node_3d().shuttle
	self.track   = get_parent_node_3d().track
	
	self.collector = get_node("Collector")
	self.collector.area_entered.connect(collect)
	self.ability_bar = get_parent().get_node("PlayerCamera/PlayMenu/AbilityBar")


func _process(delta):
	# check for ability activations
	if self.score >= 100:
		self.ability_bar.get_node("SpaceAbility/Sprite3D").modulate = Color(1, 1, 1, 1)
	else:
		self.ability_bar.get_node("SpaceAbility/Sprite3D").modulate = Color(1, 1, 1, 0.2)


func player_collide(obs):
	if self.invincible: return
	
	self.score -= 100
	self.frozen = true
	self.set_physics_process(false)
	
	var timer = get_tree().create_timer(0.25)
	timer.timeout.connect(func():
		var voices = DisplayServer.tts_get_voices_for_language("en")
		var voice_id = voices[0]
		DisplayServer.tts_speak("oof!", voice_id, 100)
	)
	$CollisionSoundA.play()
	$CollisionSoundB.play(0.2)
	$CollisionSoundC.play()
	get_tree().root.get_child(0).get_node("MainTrack").set_stream_paused(true)
	$CollisionSoundB.finished.connect(func():
		var tween = get_tree().create_tween()
		var camera = get_viewport().get_camera_3d()
		var start = camera.global_position
		#tween.tween_method(func(t):
			#camera.global_position += camera.global_basis.z*t
		#, 0, 1, 0.5).set_trans(Tween.TRANS_ELASTIC)
		self.collision_camera_position = camera.global_position
		get_parent().waiting = true
		tween.tween_property(camera, "global_position", (camera.global_position+camera.global_basis.z*20), 0.5).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_callback(func():
			var action = InputEventAction.new()
			action.action = "RollContinue"
			action.pressed = true
			Input.parse_input_event(action)
		)
	)


func recover_roll():
	var tween = get_tree().create_tween()
	var camera = get_viewport().get_camera_3d()
	var start = camera.global_position
	#tween.tween_method(func(t):
		#camera.global_position -= camera.global_basis.z*t
	#, 0, 1, 0.5).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(camera, "global_position", self.collision_camera_position, 0.5).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_callback(func():
		self.frozen = false
		self.invincible = true
		get_parent().waiting = false
		self.set_physics_process(true)
		var timer = get_tree().create_timer(1)
		timer.timeout.connect(func(): self.invincible = false)
	)


func collect(area):
	if area.has_method("collect"):
		print("Collecting: ", area.name)
		var val = area.collect(self)
		self.score += val
		$SmallCollectedSound.play()
		#if self.last_score_bloop == 0 or self.score-self.last_score_bloop > 2:
			#self.last_score_bloop = self.score
		print("Score: ", self.score)


func _input(event):
	if not self.starting:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_LEFT:
				self.pulling = event.pressed
		
		if Input.is_action_just_pressed("Ability_SpaceAbility"):
			if self.score >= 100:
				self.ability_mode = ABILITIES.SPACE
				self.frozen = true
				self.score -= 100
				print("Space Mode")
		elif Input.is_action_just_released("Ability_SpaceAbility") and self.ability_mode == ABILITIES.SPACE:
			self.ability_mode = ABILITIES.NONE
			self.frozen = false
			print("Normal Mode")


func _physics_process(delta):
	#if self.ability_mode == ABILITIES.NONE and self.frozen: return
	if not self.starting:
		var current_progress = self.shuttle.progress_ratio*self.track.curve.get_baked_length()
		var track_position = self.track.curve.sample_baked(current_progress)
		var track_tangent = self.track.curve.sample_baked(current_progress + 0.1) - track_position
		var up_vec = self.track.curve.sample_baked_up_vector(current_progress)
		
		var vec = Vector3(0, 0, 0)
		var camera = get_viewport().get_camera_3d()
		var camera_look_point = self.camera_lookpoint
		var viewport_size = get_viewport().get_visible_rect().size
		var aspect = viewport_size.x/viewport_size.y
		
		# determine our velocity
		if self.ability_mode == ABILITIES.NONE:
			if self.pulling:
				var mpos = get_viewport().get_mouse_position()
				mpos /= viewport_size
				mpos -= Vector2(0.5, 0.5)
				mpos *= Vector2(aspect, -1)
				vec = Vector3(mpos.x, mpos.y, 0)*1.3
				camera.fov -= 10*delta
				camera_look_point -= 2*delta
			else:
				camera.fov += 30*delta
				camera_look_point += 2*delta
			camera.fov = clamp(camera.fov, 75.0, 85.0)
			self.camera_lookpoint = clamp(camera_look_point, 5.0, 15.0)
			
			var diff = track_position-self.global_position
			self.velocity += (to_global(vec*800)-self.global_position)*delta
			self.velocity *= 0.9
			self.velocity += sign(diff)*diff*diff*0.1


		elif self.ability_mode == ABILITIES.SPACE:
			var mpos = camera.project_position(get_viewport().get_mouse_position(), 20)
			var pos = mpos - self.global_position
			var track_diff = track_position - self.global_position
			#var norm = self.basis.y.cross(track_diff).normalized()
			var norm = track_tangent
			self.velocity = (pos - pos.project(norm))/delta*0.1
			#self.global_position += pos - pos.project(norm)
		else:
			print("Bad ability mode!")

		# adjust camera looking position
		camera.position += -self.velocity*0.005*Vector3(-1, -1/aspect, 0)
		var point = self.track.curve.sample_baked(current_progress+self.camera_lookpoint)
		camera.look_at(point)
		var collision = move_and_collide(self.velocity*delta)
		if collision:
			print("Collided", collision)
			var collider = collision.get_collider()
			self.collided.emit(collider)
			if collider.has_meta("game_obstacle"):
				print("Game over!")
	else:
		# code for start sequence
		pass
