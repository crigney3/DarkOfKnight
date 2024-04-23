extends CharacterBody2D

@export var walkSpeed = 200
var screenSize
var isAttacking
signal getHitByEnemy
signal loseLevel
signal attack
var lastFrameVelocity : Vector2
var health
var collision
@export var levelStartPos = Vector2.ZERO
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToDescent : float

var jumpVelocity : float
var jumpGravity : float
var fallGravity : float

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_viewport_rect().size
	show()
	position = levelStartPos
	$CollisionShape2D.disabled = false
	velocity = Vector2.ZERO
	isAttacking = false
	health = 3
	jumpVelocity = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
	jumpGravity = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
	fallGravity = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0

func _physics_process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * walkSpeed
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		jump()
		
	move_and_slide()
	
	if !isAttacking:
		if velocity.x != 0 or velocity.y != 0:
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
	else:
		if lastFrameVelocity.x < 0 and velocity.x > 0:
			$AnimatedSprite2D.flip_h = true
		if lastFrameVelocity.x > 0 and velocity.x < 0:
			$AnimatedSprite2D.flip_h = false
		
	if Input.is_action_just_pressed("Attack"):
		$AnimatedSprite2D.animation = "attack"
		$AnimatedSprite2D.flip_v = false
		$AnimatedSprite2D.flip_h = velocity.x < 0
		attack.emit()
		isAttacking = true
		
	$AnimatedSprite2D.play()
	
	lastFrameVelocity = velocity
	
func get_gravity() -> float:
	return jumpGravity if velocity.y < 0.0 else fallGravity

func jump():
	velocity.y = jumpVelocity
	
func get_input_velocity() -> float:
	var horizontal := 0.0
	
	if Input.is_action_pressed("moveRight"):
		horizontal += 1.0
	if Input.is_action_pressed("moveLeft"):
		horizontal -= 1.0
		
	return horizontal

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	health -= 1
	getHitByEnemy.emit()
	if health <= 0:
		hide()
		loseLevel.emit()
		$CollisionShape2D.set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_looped():
	if isAttacking:
		isAttacking = false
