class_name Button3D extends Area3D

enum ACTIONS {NONE, PAUSE_GAME, RESTART_GAME, EXIT_GAME, START_GAME}
const action_name_map = {
	ACTIONS.NONE: null,
	ACTIONS.PAUSE_GAME: "PauseGame",
	ACTIONS.RESTART_GAME: "RestartGame",
	ACTIONS.EXIT_GAME: "ExitGame",
	ACTIONS.START_GAME: "StartGame"
}
var action_name: String

@export var action: ACTIONS = ACTIONS.NONE
@export var sound_source: AudioStreamWAV
@export var action_on_sound_finish: bool = false
@export var action_delay: float = 0.0

signal activated

var sound_player: AudioStreamPlayer

func _ready():
	self.action_name = action_name_map[self.action]
	connect("input_event", self.handle)
	if self.sound_source != null:
		self.sound_player = AudioStreamPlayer.new()
		self.sound_player.stream = sound_source
		if self.action_on_sound_finish:
			self.sound_player.connect("finished", self._call_action)
		add_child(self.sound_player)

func handle(camera, event, pos, norm, idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			print("Clicked! Running %s" % name)
			if self.sound_source != null:
				print("Playing sound")
				self.sound_player.play()
				if not self.action_on_sound_finish:
					self._call_action()
			else:
				self._call_action()


func _call_action():
	if self.action_delay != 0.0:
		var timer = get_tree().create_timer(self.action_delay)
		timer.timeout.connect(func(): self._send_action())
	else:
		self._send_action()

func _send_action():
	if self.action_name == null: self.activated.emit()
	else:
		var e = InputEventAction.new()
		e.action = self.action_name
		e.pressed = true
		Input.parse_input_event(e)


func _process(delta):
	pass
