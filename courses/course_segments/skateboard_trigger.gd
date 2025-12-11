extends Area2D

@export var skateboard : bool = true;
func _ready() -> void:
	self.body_entered.connect(func(body : PhysicsBody2D):
		if body is RacingBug:
			if skateboard:
				body.skate();
			else:
				body.end_skate();
	);
