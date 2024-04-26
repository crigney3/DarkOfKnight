extends Control

var mainGameScene = preload("res://Scenes/Main.tscn").instantiate()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_pressed():
	# Play button
	get_node("/root/MainMenuScene").queue_free()
	get_tree().root.add_child(mainGameScene)


func _on_button_2_pressed():
	# Quit button
	get_tree().quit()
