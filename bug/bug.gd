class_name Bug extends Sprite2D

@onready var window : Window = self.get_window();
@onready var _end_adventure : Button = $EndAdventure;

signal adventure_ended();

var _screen_size : Vector2i;
var _adventuring : bool = false;

var extents : Rect2i;

func _ready():
	_initialize_adventure();
	_end_adventure.pressed.connect(end_adventure);

func jump(callback : Callable = Callable()):
	var tween = create_tween();
	var squash_amount : float = 0.8;
	tween.tween_property(self, "scale", Vector2(1.2, squash_amount), 0.2);
	tween.parallel();
	tween.tween_property(self, "position", self.position + Vector2(0, (150.0 * (1.0 - squash_amount))/2.0), 0.2);
	
	tween.tween_property(self, "scale", Vector2(0.6, 1.5), 0.2).set_delay(0.05);
	tween.parallel();
	tween.tween_property(self, "position", self.position + Vector2.UP * 400, 0.2).set_delay(0.05);
	tween.tween_callback(callback);

func land(delay : float, start : Vector2, pos : Vector2, callback : Callable):
	var tween = create_tween();
	tween.tween_property(self, "position", pos, 0.1).from(start).set_delay(delay);
	tween.parallel();
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5).from(Vector2(0.6, 1.5));
	tween.tween_callback(callback).set_delay(0.01);

func begin_adventure():
	_adventuring = true;
	_screen_size = DisplayServer.screen_get_size(window.current_screen);

func end_adventure():
	_adventuring = false;
	adventure_ended.emit();
	_end_adventure.visible = false;

var _adventure_dir : float = 1;

var _adventure_delta_update : float = 0;

var _adventure_noise : FastNoiseLite = FastNoiseLite.new();

func _initialize_adventure() -> void:
	_adventure_noise.noise_type = FastNoiseLite.TYPE_PERLIN;

func _input(event: InputEvent) -> void:
	if !_adventuring:
		return;
	if event is InputEventMouseMotion:
		var pos = event.position;
		pos.x -= extents.size.x/2.0;
		pos.y -= extents.size.y/2.0;
		_end_adventure.visible = self.get_rect().has_point(to_local(pos));
		# window.mouse_passthrough = !_end_adventure.visible;

func _notification(what: int) -> void:
	match what:
		MainLoop.NOTIFICATION_APPLICATION_FOCUS_OUT, NOTIFICATION_WM_MOUSE_EXIT:
			_end_adventure.visible = false;

func _process(delta: float) -> void:
	if _adventuring:
		var passthrough_polygon = PackedVector2Array();
		
		var rect = get_rect();
		rect.position += extents.size/2.0 + self.global_position;
		const MARGIN : float = 10.0;
		
		passthrough_polygon.push_back(rect.position + Vector2(-MARGIN, -MARGIN));
		passthrough_polygon.push_back(rect.position + Vector2(rect.size.x + MARGIN, -MARGIN));
		passthrough_polygon.push_back(rect.position + Vector2(rect.size.x + MARGIN, rect.size.y + MARGIN));
		passthrough_polygon.push_back(rect.position + Vector2(-MARGIN, rect.size.y + MARGIN));
		
		window.mouse_passthrough_polygon = passthrough_polygon;
		_adventure_delta_update += delta;
		
		_adventure_dir = _adventure_noise.get_noise_1d(Time.get_ticks_msec()/500.0);
		if self.position.x + extents.size.x/2.0 > extents.end.x - 250 && _adventure_dir > 0:
			_adventure_dir = 0;
		elif self.position.x + extents.size.x/2.0 < extents.position.x + 250 && _adventure_dir < 0:
			_adventure_dir = 0;
		
		self.position.x += _adventure_dir;
