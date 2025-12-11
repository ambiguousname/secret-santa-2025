class_name RacingBug extends RigidBody2D

var stats : Stats = Stats.new();

enum State {
	RUNNING,
	CLIMBING,
	FALLING,
	SKATING,
	JUMPING,
};
var state : State = State.FALLING;

func _ready() -> void:
	self.contact_monitor = true;
	self.max_contacts_reported = 4;
	self.body_entered.connect(func(body : PhysicsBody2D): 
		if state != State.FALLING:
			return;
		if body is StaticBody2D:
			if test_move(transform, Vector2.DOWN):
				state = State.RUNNING;
			else:
				print("Climb");
				state = State.CLIMBING;
	);

func _physics_process(delta: float) -> void:
	match state:
		State.RUNNING:
			if get_contact_count() == 0:
				state = State.FALLING;
				return;
			self.apply_force(Vector2.RIGHT * (stats.running.level + 1));
	#self.apply_force(Vector2(1, -1) * 1000.0);
