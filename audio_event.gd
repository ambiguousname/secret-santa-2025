extends Node

signal played(name : String);

func play(name : String):
	played.emit(name);
