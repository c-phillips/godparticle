extends Control

signal finished

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("IntroCinematic")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_animation_player_animation_finished(anim_name):
	self.finished.emit()
	self.queue_free()


func _on_button_pressed():
	self.finished.emit()
	self.queue_free()
