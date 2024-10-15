class_name NameGenerator extends RefCounted

static var names: PackedStringArray = []

static var special_names: Array[String] = [
	"developerezra",
	"zuzu",
	"bruno",
	"jonas",
	"sigh_bold",
	"nopey",
	"breekkk"
]
static func get_random_name():
	if names.is_empty():
		_load_names()
	return names[randi_range(0, names.size() - 1)]
	
static func _load_names():
	var file = FileAccess.open("res://members/names.txt", FileAccess.READ)
	var content = file.get_as_text()
	names = content.split(",")
