extends Sprite2D

@onready var _initial_pos : Vector2 = self.position;
@onready var window : Window = self.get_window();

var _screen_size : Vector2i;
var _adventuring : bool = false;
func begin_adventure():
	_adventuring = true;
	_screen_size = DisplayServer.screen_get_size(window.current_screen);

var _adventure_dir : int = 1;

var _adventure_delta_update : float = 0;

func _process(delta: float) -> void:
	if _adventuring:
		_adventure_delta_update += delta;
		
		if self.position.x > _screen_size.x - 500:
			_adventure_dir *= -1;
		elif self.position.x < 500 && _adventure_dir == -1:
			_adventure_dir *= -1;
		
		self.position.x += _adventure_dir;
