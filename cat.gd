extends Control


var player_score: int = 0;
const max_bar_height: int = 800
const min_bar_height: int = 100

var current_cat
var last_bar_update = 0.0
const bar_update_interval = 200  # ms

# Called when the node enters the scene tree for the first time.
func _ready():
	self.current_cat = $Container/Good


func update_score(score):
	self.player_score = score
	$Container/Label.text = "%04d" % self.player_score
	if Time.get_ticks_msec() - self.last_bar_update > self.bar_update_interval:
		self.last_bar_update = Time.get_ticks_msec()
		var bar_height = int(min(max(self.player_score, self.min_bar_height), self.max_bar_height))
		var tween = get_tree().create_tween()
		tween.tween_method($Container/ScoreBar.set_size, $Container/ScoreBar.get_size(), Vector2(24, bar_height), 0.15).set_trans(Tween.TRANS_ELASTIC)
	
	var new_cat
	if self.player_score < 100:
		new_cat = $Container/Bad
	elif self.player_score < 400:
		new_cat = $Container/Good
	else:
		new_cat = $Container/Max
	if new_cat != self.current_cat:
		self.current_cat.hide()
		self.current_cat = new_cat
		self.current_cat.show()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
