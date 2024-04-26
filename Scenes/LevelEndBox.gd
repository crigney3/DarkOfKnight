extends Node2D

signal winLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	winLevel.emit()

func _on_body_entered(body):
	print("body entered")


func _on_win_level():
	pass
