extends Control

var currentLevel
var nextLevel
const level1String = "res://Scenes/Levels/Level1.tscn"
const level2String = "res://Scenes/Levels/Level2.tscn"
const level3String = "res://Scenes/Levels/Level3.tscn"
const level4String = "res://Scenes/Levels/Level4.tscn"
const level5String = "res://Scenes/Levels/Level5.tscn"
var nextLevelPreloaded
var nextLevelUI

# Called when the node enters the scene tree for the first time.
func _ready():
	currentLevel = 1
	nextLevel = 2
	nextLevelPreloaded = preload(level2String).instantiate()
	nextLevelUI = get_tree().get_first_node_in_group("LevelWinUI")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func loadNextLevel():
	get_node("/root/Main/Level1").free()
	currentLevel += 1
	nextLevel += 1
	nextLevelUI.set_visible(false)
	get_tree().root.get_child(0).add_child(nextLevelPreloaded)
	get_node("/root/Main/PlayerScene").setLevelStartPosition(50, 400)
	if currentLevel == 2:
		nextLevelPreloaded = preload(level3String).instantiate()
	elif currentLevel == 3:
		nextLevelPreloaded = preload(level4String).instantiate()


func _on_button_pressed():
	loadNextLevel()
