class_name Course extends Node2D

@onready var finish : Area2D = $Finish;
@onready var kill : Area2D = $KillPlane;

func _ready() -> void:
	if OS.is_debug_build():
		var args = OS.get_cmdline_args();
		
		var scene_arg = args.find("--scene");
		if scene_arg >= 0 && scene_arg + 1 < args.size():
			var scene_name = args[scene_arg + 1];
			
			if scene_name == get_tree().current_scene.scene_file_path:
				start_race();

func start_race():
	print("A");
