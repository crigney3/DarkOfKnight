extends Node2D

signal winLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_area_2d_body_entered(body: CharacterBody2D) -> void:
	winLevel.emit()
	print("a")

func _on_body_entered(body):
	print("a")
