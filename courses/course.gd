class_name Course extends Node2D

@onready var racer_start : Node2D = $RacerStart;
@onready var finish : Area2D = $Finish;
@onready var kill : Area2D = $KillPlane;
@onready var camera : PhantomCamera2D = $PhantomCamera2D;

@onready var end_timer : Timer = $Timer;
@onready var time_left : Label = $RacingCamera/RaceUI/TimeLeft;

@export var mean : float = 6.0;
@export var std : float = 1.0;

signal race_end(player_win : bool);

var winner : bool = false;

func _ready() -> void:
	end_timer.timeout.connect(func():
		end_race(false);
	);
	kill.body_entered.connect(func(b : PhysicsBody2D):
		if b is RacingBug:
			racing_bugs.remove_at(racing_bugs.find(b));
			if b.player:
				end_race(false);
			b.queue_free();
		# TODO: Failure code
	);
	
	finish.body_entered.connect(func(b : PhysicsBody2D):
		if b is RacingBug:
			if b.player && !winner:
				end_race(true);
			winner = true;
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
				#tmp.climbing.level = 10;
				#tmp.jumping.level = 25;
				start_race(tmp);

func _process(delta: float) -> void:
	if race_done:
		return;
	if end_timer.time_left < 10:
		time_left.visible = true;
		time_left.text = str(int(end_timer.time_left));

var racing_bug = preload("uid://bylxu2i2xmwp1");
var racing_bugs : Array[RacingBug] = [];

func start_race(player_bug_stats : Stats):
	racing_bugs.clear();
	var bug : RacingBug = add_racer(player_bug_stats);
	bug.player = true;
	camera.follow_target = bug;
	
	var stat_gen = RandomNumberGenerator.new();
	stat_gen.randomize();
	
	for i in range(3):
		var stats = Stats.new();
		stats.running.level = max(round(stat_gen.randfn(mean, std)), 0);
		stats.climbing.level = max(round(stat_gen.randfn(mean, std)), 0);
		stats.skateboarding.level = max(round(stat_gen.randfn(mean, std)), 0);
		stats.jumping.level = max(round(stat_gen.randfn(mean, std)), 0);
		#print("%d %d %d %d" % [stats.running.level, stats.climbing.level, stats.skateboarding.level, stats.jumping.level]);
		add_racer(stats);
	end_timer.start();

func add_racer(stats : Stats) -> RacingBug:
	var bug : RacingBug = racing_bug.instantiate();
	bug.stats = stats;
	# Start with random angular velocity:
	bug.angular_velocity = randf();
	
	racing_bugs.push_back(bug);
	racer_start.add_child(bug);
	return bug;

var race_done : bool = false;
func end_race(player_win : bool):
	race_done = true;
	time_left.visible = false;
	race_end.emit(player_win);

func cleanup_race():
	for b in racing_bugs:
		b.queue_free();
	racing_bugs.clear();
