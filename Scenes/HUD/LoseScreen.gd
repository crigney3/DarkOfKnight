extends Control

var level1Preloaded

# Called when the node enters the scene tree for the first time.
func _ready():
	level1Preloaded = preload("res://Scenes/Levels/Level1.tscn").instantiate()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	get_node("/root/Main/Level1").free()
	get_tree().root.get_child(0).add_child(level1Preloaded)
	get_node("/root/Main/PlayerScene").setLevelStartPosition(50, 400)
