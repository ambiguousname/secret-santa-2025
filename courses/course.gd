class_name Course extends Node2D

@onready var racer_start : Node2D = $RacerStart;
@onready var finish : Area2D = $Finish;
@onready var kill : Area2D = $KillPlane;

func _ready() -> void:
	if OS.is_debug_build():
		var args = OS.get_cmdline_args();
		
		var scene_arg = args.find("--scene");
		if scene_arg >= 0 && scene_arg + 1 < args.size():
			var scene_name = args[scene_arg + 1];
			
			if scene_name == get_tree().current_scene.scene_file_path:
				setup_race(Stats.new());

var racing_bug = preload("uid://bylxu2i2xmwp1");
var racing_bugs : Array[RacingBug] = [];

func setup_race(player_bug_stats : Stats):
	racing_bugs.clear();
	add_racer(player_bug_stats);
	for i in range(3):
		add_racer(Stats.new());

func add_racer(stats : Stats):
	var bug : RacingBug = racing_bug.instantiate();
	bug.stats = stats;
	
	racing_bugs.push_back(bug);
	racer_start.add_child(bug);

func cleanup_race():
	for b in racing_bugs:
		b.queue_free();
	racing_bugs.clear();
