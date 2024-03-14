extends Node3D


enum MODE {ALIVE, DEAD, INVINCIBLE}
@export var gamemode: MODE = MODE.ALIVE

var track: Path3D
var player: Player

var level_resource = preload("res://level_base.tscn")
var roll_arena = preload("res://roll_test.tscn")
var cinematic_scene = preload("res://intro_cinematic.tscn")

var seen_intro = false
var mode_lock = false
var ready_to_play = true

# Called when the node enters the scene tree for the first time.
func _ready():
	self.restart()

func _input(event):
	if event.is_action("ExitGame"):
		print("Quitting")
		get_tree().quit()
	elif event.is_action("RestartGame"):
		self.mode_lock = true
		self.restart()
		self.mode_lock = false
	elif event.is_action("StartGame"):
		#if not self.ready_to_play:
			#$LoadingBar.show()
			#while not self.ready_to_play:
				#pass
			#$LoadingBar.hide()
		$Options.hide()
		if not self.seen_intro:
			if $Options/Container/WatchIntroButton.button_pressed:
				print("Staring with intro cinematic")
				await self.show_intro_cinematic()
				self.seen_intro = true
		print("Starting")
		Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
		var voices = DisplayServer.tts_get_voices_for_language("en")
		var voice_id = voices[0]
		DisplayServer.tts_speak("Now, go my child!", voice_id, 100)
		$WaitingMusic.stop()
		$MainTrack.play(10.4)
		$LevelBase/Hand/AnimationPlayer.play("FingerGunShoot")
		self.player.start_play()
	elif event.is_action("RollContinue") and not self.mode_lock:
		$MainTrack.set_stream_paused(true)
		self.mode_lock = true
		print("Rolling!")
		#get_tree().paused = true
		var roller = roll_arena.instantiate()
		roller.finished.connect(_handle_roll_result)
		add_child(roller)
		roller.roll($LevelBase/Track/Shuttle.progress_ratio)
	else:
		if Input.is_action_just_released("PauseGame") and not self.mode_lock:
			if not get_tree().paused:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				$WaitingMusic.play()
				print("pause")
				$MainTrack.playing = false
				var player = $LevelBase/Track/Shuttle/Player/PlayerBody
				var pcam = $LevelBase/Track/Shuttle/Player/PlayerCamera
				var shuttle = $LevelBase/Track/Shuttle
				$Menu.global_position = self.track.curve.sample_baked(shuttle.progress_ratio*self.track.curve.get_baked_length()-3)
				$Menu.look_at(pcam.global_position)
				$Menu.rotate_object_local(Vector3.UP, PI)
				get_tree().paused = true
				$Menu.show()
				$Menu.pause()
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
				print("unpause")
				$WaitingMusic.stop()
				$Menu.unpause()
				$MainTrack.playing = true


func show_intro_cinematic():
	print("creating cinematic node")
	var cinematic = self.cinematic_scene.instantiate()
	add_child(cinematic)
	print("Waiting to finish cinematic")
	return cinematic.finished


func _handle_roll_result(result: int):
	print("Finished rolling: ", result)
	self.mode_lock = false
	if result >= 5:
		#get_tree().paused = false
		$MainTrack.set_volume_db(-20.0)
		$MainTrack.set_stream_paused(false)
		var tween = get_tree().create_tween()
		tween.tween_method($MainTrack.set_volume_db, -20.0, 0.0, 1.5)
		self.player.character.recover_roll()
	else:
		$GameOverA.play()
		$GameOverB.play()
		$GameOverC.play()
		self.game_over()


func game_over():
	self.restart()


func restart():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	print("Restarting")
	if get_tree().paused:
		print("unpausing for reload")
		$Menu.unpause(true)
	$LevelBase.free()
	$Options.show()
	$Options/Container/WatchIntroButton.button_pressed = !self.seen_intro
	self.instance_environment()
	var timer = get_tree().create_timer(0.5)
	timer.timeout.connect(func():
		$WaitingMusic.set_volume_db(-20.0)
		$WaitingMusic.play()
		var tween = get_tree().create_tween()
		tween.tween_method($WaitingMusic.set_volume_db, -20.0, 0.0, 1.5)
	)


func _handle_player_collision(body):
	print("Contact")
	if body.has_method("contact"):
		body.contact()


func _winner():
	$LoadingBar.show()
	get_tree().paused = true
	$LoadingBar/Label.text = "%07.2f" % self.player.runtime
	$WinnerSounds.play()


func instance_environment():
	self.ready_to_play = false
	if get_node("LevelBase") == null:
		print("loading new level")
		var level_base = level_resource.instantiate()
		level_base.set_name("LevelBase")
		add_child(level_base)
	
	self.track = $LevelBase/Track
	self.track.get_node("Shuttle").finished.connect(self._winner)
	self.player = $LevelBase/Track/Shuttle/Player
	self.player.character.collided.connect(_handle_player_collision)
	self.player.get_node("PlayerCamera").current = true

