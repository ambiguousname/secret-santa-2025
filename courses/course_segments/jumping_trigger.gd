extends Area2D

func _ready() -> void:
	self.body_entered.connect(func(body : PhysicsBody2D):
		if body is RacingBug:
			body.jump();
	);
