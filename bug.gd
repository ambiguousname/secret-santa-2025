class_name Bug extends Sprite2D

@onready var _initial_pos : Vector2 = self.position;
@onready var window : Window = self.get_window();

var _screen_size : Vector2i;
var _adventuring : bool = false;

func jump():
	var tween = create_tween();
	var squash_amount : float = 0.8;
	tween.tween_property(self, "scale", Vector2(1.2, squash_amount), 0.2);
	tween.parallel();
	tween.tween_property(self, "position", self.position + Vector2(0, (150.0 * (1.0 - squash_amount))/2.0), 0.2);
	
	tween.tween_property(self, "scale", Vector2(0.6, 1.5), 0.2).set_delay(0.05);
	tween.parallel();
	tween.tween_property(self, "position", self.position + Vector2.UP * 400, 0.2).set_delay(0.05);

func land(delay : float, start : Vector2, pos : Vector2, callback : Callable):
	var tween = create_tween();
	tween.tween_property(self, "position", pos, 0.1).from(start).set_delay(delay);
	tween.parallel();
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).from(Vector2(0.6, 1.5));
	tween.finished.connect(callback);

func begin_adventure():
	_adventuring = true;
	_screen_size = DisplayServer.screen_get_size(window.current_screen);

var _adventure_dir : int = 1;

var _adventure_delta_update : float = 0;
func _process(delta: float) -> void:
	if _adventuring:
		_adventure_delta_update += delta;
		
		if self.position.x + 50 > _screen_size.x - 750:
			_adventure_dir *= -1;
		elif self.position.x < 500 && _adventure_dir == -1:
			_adventure_dir *= -1;
		
		self.position.x += 100.0 * _adventure_dir * delta;
