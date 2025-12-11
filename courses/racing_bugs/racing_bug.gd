class_name RacingBug extends RigidBody2D

var stats : Stats = Stats.new();

func _physics_process(delta: float) -> void:
	self.apply_force(Vector2(1, -1) * 200.0);
