extends Node2D

var peer : StreamPeerTCP = StreamPeerTCP.new();
var sent_acknowledgement : bool = false;
var acknowledged : bool = false;
func _ready() -> void:
	print(peer.connect_to_host("127.0.0.1", 5121));

const MAGIC_SEND : String = "BuddyClient";
const MAGIC_RECEIVE : String = "BuddyServer";

func _process(delta: float) -> void:
	if peer == null:
		return;
	peer.poll();
	if peer.get_status() == peer.STATUS_CONNECTED:
		if !sent_acknowledgement:
			peer.put_data(MAGIC_SEND.to_ascii_buffer());
			sent_acknowledgement = true;
		var available_bytes = peer.get_available_bytes();
		if available_bytes > 0:
			if !acknowledged && available_bytes >= MAGIC_RECEIVE.length():
				var out = peer.get_string(MAGIC_RECEIVE.length());
				if out != MAGIC_RECEIVE:
					peer.disconnect_from_host();
					return;
				acknowledged = true;
				return;
			else:
				pass;
