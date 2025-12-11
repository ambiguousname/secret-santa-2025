class_name Course extends Node2D

@onready var racer_start : Node2D = $RacerStart;
@onready var finish : Area2D = $Finish;
@onready var kill : Area2D = $KillPlane;
@onready var camera : PhantomCamera2D = $PhantomCamera2D;

@onready var end_timer : Timer = $Timer;

func _ready() -> void:
	end_timer.timeout.connect(end_race);
	kill.body_entered.connect(func(b : PhysicsBody2D):
		if b is RacingBug:
			racing_bugs.remove_at(racing_bugs.find(b));
			b.queue_free();
		# TODO: Failure code
	);
	if OS.is_debug_build():
		var args = OS.get_cmdline_args();
		
		var scene_arg = args.find("--scene");
		if scene_arg >= 0 && scene_arg + 1 < args.size():
			var scene_name = args[scene_arg + 1];
			
			if scene_name == get_tree().current_scene.scene_file_path:
				var tmp = Stats.new();
				#tmp.running.level = 100;
				#tmp.skateboarding.level = 10;
				#tmp.jumping.level = 25;
				start_race(tmp);

var racing_bug = preload("uid://bylxu2i2xmwp1");
var racing_bugs : Array[RacingBug] = [];

func start_race(player_bug_stats : Stats):
	racing_bugs.clear();
	var bug : RacingBug = add_racer(player_bug_stats);
	camera.follow_target = bug;
	
	for i in range(3):
		add_racer(Stats.new());
	end_timer.start();

func add_racer(stats : Stats) -> RacingBug:
	var bug : RacingBug = racing_bug.instantiate();
	bug.stats = stats;
	
	racing_bugs.push_back(bug);
	racer_start.add_child(bug);
	return bug;

func end_race():
	print("RACE ENDED");
	cleanup_race();

func cleanup_race():
	for b in racing_bugs:
		b.queue_free();
	racing_bugs.clear();
