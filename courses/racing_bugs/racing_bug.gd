class_name RacingBug extends RigidBody2D

@onready var skateboard : Sprite2D = $Skateboard;
@onready var sprite : AnimatedSprite2D = $Sprite2D;

var stats : Stats = Stats.new();
var player : bool = false;

var eye_color : Color:
	set(v):
		sprite.material.set_shader_parameter("eye_color", v);
var color : Color:
	set(v):
		sprite.material.set_shader_parameter("body_tint", v);
	get():
		return sprite.material.get_shader_parameter("body_tint");

var secondary_color : Color:
	set(v):
		sprite.material.set_shader_parameter("secondary_tint", v);

var pattern : int:
	set(v):
		sprite.material.set_shader_parameter("pattern", v);

enum State {
	RUNNING,
	CLIMBING,
	FALLING,
	FALLING_RIGHT,
	SKATING,
	JUMPING,
};
var state : State = State.FALLING;

@onready var skate_sound : AudioStreamPlayer2D = $Skate;
func skate():
	skateboard.visible = true;
	state = State.SKATING;
	skate_sound.pitch_scale = 0.5 * randf() + 0.5;
	skate_sound.volume_db = AudioEvent.get_volume_db(AudioEvent.AudioType.SFX);
	skate_sound.play();

func end_skate():
	skateboard.visible = false;
	state = State.FALLING;
	skate_sound.stop();

func jump():
	state = State.JUMPING;

func _ready() -> void:
	self.contact_monitor = true;
	self.max_contacts_reported = 4;
	sprite.play();
	#self.body_entered.connect(func(b : PhysicsBody2D):
	#);
	#self.body_entered.connect(func(body : PhysicsBody2D): 
		#if state != State.FALLING:
			#return;
		#if body is StaticBody2D:
			#if test_move(transform, Vector2.DOWN):
				#state = State.RUNNING;
			#else:
				#print("Climb");
				#state = State.CLIMBING;
	#);

@onready var hit : AudioStreamPlayer2D = $Hit;
@onready var jump_sound : AudioStreamPlayer2D = $Jump;
func play_jump_sound():
	jump_sound.volume_db = AudioEvent.get_volume_db(AudioEvent.AudioType.SFX);
	jump_sound.pitch_scale = 0.5 + 0.5 * randf();
	jump_sound.play();

func _integrate_forces(st: PhysicsDirectBodyState2D) -> void:
	match state:
		State.FALLING, State.FALLING_RIGHT:
				
			for i in range(st.get_contact_count()):
				var down = st.get_contact_local_position(i) - global_position;
				if down.normalized().dot(Vector2.DOWN) > 0.5:
					hit.pitch_scale = 0.5 + randf() * 0.5;
					hit.volume_db = AudioEvent.get_volume_db(AudioEvent.AudioType.SFX);
					hit.play();
					state = State.RUNNING;
					return;
			# If we've evaluated all contact points and we're not running, we must be climbing:
			if st.get_contact_count() > 0:
				self.linear_velocity = Vector2.ZERO;
				state = State.CLIMBING;
				return;
		State.SKATING:
			#if st.get_contact_count() > 0:
				#self.linear_velocity += Vector2(1, -1) * st.step * pow(stats.skateboarding.level + 1, 2);
				#self.linear_velocity += Vector2(0, -1) * 980 * st.step;
			for i in range(st.get_contact_count()):
				var normal = st.get_contact_local_normal(i);
				var perp = normal.rotated(PI/2);
				#var mult = 30;
				#if align > 0.5:
					#mult = 100;
				self.linear_velocity += st.step * perp * 135 * (stats.skateboarding.level + 1);
				self.angular_velocity += 0.01;
		State.CLIMBING:
			self.linear_velocity += Vector2.UP * 985 * st.step;
			for i in range(st.get_contact_count()):
				var normal = st.get_contact_local_normal(i);
				self.linear_velocity += normal.rotated(PI/2) * (stats.climbing.level + 1) * st.step;
			if st.get_contact_count() == 0:
				self.linear_velocity += Vector2.UP * 980.0 * st.step * 20.0;
				self.linear_velocity += Vector2.UP * stats.jumping.level;
				play_jump_sound();
				state = State.FALLING_RIGHT;
				return;
		State.JUMPING:
			if st.get_contact_count() > 0:
				self.linear_velocity += Vector2(0, -10000) * st.step;
				self.linear_velocity += Vector2(1, -1) * 5 * pow(stats.jumping.level + 1, 2) * st.step;
				play_jump_sound();
				state = State.FALLING;

func _physics_process(delta: float) -> void:
	match state:
		State.RUNNING:
			if get_contact_count() == 0:
				state = State.FALLING;
				return;
			self.apply_force(Vector2.RIGHT * (stats.running.level + 1));
		State.FALLING_RIGHT:
			self.apply_force(Vector2.RIGHT * 100.0);
			
	#self.apply_force(Vector2(1, -1) * 1000.0);
