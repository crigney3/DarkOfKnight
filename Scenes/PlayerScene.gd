extends Area2D

@export var walkSpeed = 200
var screenSize
var velocity
var isJumping
signal getHitByEnemy
signal loseLevel
var health
@export var levelStartPos = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_viewport_rect().size
	show()
	position = levelStartPos
	$CollisionShape2D.disabled = false
	velocity = Vector2.ZERO
	isJumping = false
	health = 3


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("moveRight"):
		velocity.x += 1
	if Input.is_action_just_released("moveRight") and velocity.x > 0:
		velocity.x = 0
	if Input.is_action_pressed("moveLeft"):
		velocity.x -= 1
	if Input.is_action_just_released("moveLeft") and velocity.x < 0:
		velocity.x = 0
	if Input.is_action_just_pressed("Jump"):
		isJumping = true
		velocity.y += 5
	if Input.is_action_just_released("Jump"):
		isJumping = false
	if Input.is_action_pressed("Jump"):
		velocity.y += 1
		
	if velocity.length() > 0:
		velocity = velocity.normalized() * walkSpeed
		if velocity.x != 0 and velocity.y != 0:
			$AnimatedSprite2D.animation = "run_jump"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
		elif velocity.y != 0 and velocity.x == 0:
			$AnimatedSprite2D.animation = "jump"
		elif velocity.x != 0:
			$AnimatedSprite2D.animation = "walk"
			$AnimatedSprite2D.flip_v = false
			$AnimatedSprite2D.flip_h = velocity.x < 0
	else:
		$AnimatedSprite2D.animation = "idle"
		
	if Input.is_action_just_pressed("Attack"):
		$AnimatedSprite2D.animation = "attack"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
		
	$AnimatedSprite2D.play()
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screenSize)


func _on_body_entered(body):
	health -= 1
	getHitByEnemy.emit()
	if health <= 0:
		hide()
		loseLevel.emit()
		$CollisionShape2D.set_deferred("disabled", true)
