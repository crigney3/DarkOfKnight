extends Node2D	

var rangeZMin: int
var rangeZMax: int
var layerMin: int
var layerMax: int

var shadowEnabled: bool
var shadowColor: Color

var lightTexture: Texture2D
var lightOffset: Vector2
var lightTexScale: float

var lightColor: Color
var lightEnergy: float 

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimatedSprite2D.animation = "default"
	$AnimatedSprite2D.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
