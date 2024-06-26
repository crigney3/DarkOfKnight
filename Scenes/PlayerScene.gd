extends CharacterBody2D

@export var walkSpeed = 200
var screenSize
var isAttacking
var isHurt
var hurtCooldown
var currentHurtDuration
var levelWon
signal getHitByEnemy
signal loseLevel
signal attack
signal getHurtByTrapOrFalling
signal torchBoostPickedUp
signal loseHealthAndUpdateUI
var lastFrameVelocity : Vector2
var health
var collision
var levelStartPos = Vector2.ZERO
@export var jumpHeight : float
@export var jumpTimeToPeak : float
@export var jumpTimeToDescent : float

var jumpVelocity : float
var jumpGravity : float
var fallGravity : float

var levelWinUI
var levelLoseUI

var torchesArray = []

var jumpSound
var swordHitSound
var swordMissSound
var torchLightSound
var winSound
var loseLevelSound
var takeDamageSound
var musicSound

# Called when the node enters the scene tree for the first time.
func _ready():
	screenSize = get_viewport_rect().size
	show()
	position = Vector2(50, 400)
	levelStartPos = position
	$CollisionShape2D.disabled = false
	velocity = Vector2.ZERO
	isAttacking = false
	health = 3
	levelWon = false
	
	jumpVelocity = ((2.0 * jumpHeight) / jumpTimeToPeak) * -1.0
	jumpGravity = ((-2.0 * jumpHeight) / (jumpTimeToPeak * jumpTimeToPeak)) * -1.0
	fallGravity = ((-2.0 * jumpHeight) / (jumpTimeToDescent * jumpTimeToDescent)) * -1.0
	
	levelWinUI = get_tree().get_first_node_in_group("LevelWinUI")
	levelWinUI.set_visible(false)
	levelLoseUI = get_tree().get_first_node_in_group("LevelLoseUI")
	levelLoseUI.set_visible(false)
	
	hurtCooldown = 1.0
	currentHurtDuration = 0.0
	
	jumpSound = preload("res://Audio/Jump.wav")
	swordHitSound = preload("res://Audio/SwordHit.wav")
	swordMissSound = preload("res://Audio/SwordMiss.wav")
	torchLightSound = preload("res://Audio/TorchIgnition.wav")
	takeDamageSound = preload("res://Audio/TakeDamage.wav")
	loseLevelSound = preload("res://Audio/LoseLevel.wav")
	winSound = preload("res://Audio/LevelWin.wav")
	musicSound = preload("res://Audio/MainMusic.mp3")
	
	$JumpStreamPlayer2D.stream = jumpSound
	$SwordStreamPlayer2D.stream = swordMissSound
	$TorchStreamPlayer2D.stream = torchLightSound
	$HurtStreamPlayer2D.stream = takeDamageSound
	$WinStreamPlayer2D.stream = loseLevelSound
	$MusicStreamPlayer2D.stream = musicSound
	
	$MusicStreamPlayer2D.play()

func _physics_process(delta):
	velocity.y += get_gravity() * delta
	velocity.x = get_input_velocity() * walkSpeed
	
	if Input.is_action_just_pressed("Jump") and is_on_floor() and !levelWon and !isHurt:
		jump()
		
	move_and_slide()
	
	if levelWon:
		$AnimatedSprite2D.animation = "win"
		$AnimatedSprite2D.play()
		return
		
	if isHurt:
		$AnimatedSprite2D.animation = "idle_hurt"
		$AnimatedSprite2D.play()
		currentHurtDuration += delta
		if currentHurtDuration >= hurtCooldown:
			currentHurtDuration = 0.0
			isHurt = false
		
		return
	
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
	if !$JumpStreamPlayer2D.is_playing():
		$JumpStreamPlayer2D.play()
	
func get_input_velocity() -> float:
	var horizontal := 0.0
	
	if Input.is_action_pressed("moveRight"):
		horizontal += 1.0
	if Input.is_action_pressed("moveLeft"):
		horizontal -= 1.0
	if !levelWon and !isHurt:
		return horizontal
	else:
		return 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if $Torch/PointLight2D.energy > 0.15:
		$Torch/PointLight2D.range_z_max -= 32 * delta
		$Torch/PointLight2D.range_z_min += 32 * delta
		$Torch/PointLight2D.energy -= 0.25 * delta

func _on_body_entered(body):
	pass


func _on_animated_sprite_2d_animation_looped():
	if isAttacking:
		isAttacking = false

func _on_area_2d_area_entered(area):
	if area.is_in_group("levelWinBox"):
		levelWon = true
		levelWinUI.set_visible(true)
		$WinStreamPlayer2D.stream = winSound
		$WinStreamPlayer2D.play()
	if area.is_in_group("torchBoostPickup"):
		torchBoostPickedUp.emit()
		torchesArray.append(area)
		area.get_node("CollisionShape2D").set_deferred("disabled", true)
		area.get_node("Torch").visible = false
	
	if area.is_in_group("enemies"):
		getHitByEnemy.emit()
	elif area.is_in_group("pitOrTrap"):
		getHurtByTrapOrFalling.emit()
		
	if health <= 0:
		hide()
		loseLevel.emit()

func _on_torch_boost_picked_up():
	$Torch/PointLight2D.range_z_max = 1536
	$Torch/PointLight2D.range_z_min = -1536
	$Torch/PointLight2D.energy = 2.0
	$TorchStreamPlayer2D.play()

func setLevelStartPosition(x: float, y: float):
	position = Vector2(x, y)
	levelWon = false
	velocity = Vector2.ZERO
	isAttacking = false
	levelStartPos = Vector2(x, y)
	torchesArray.clear()
	health = 3
	levelLoseUI.set_visible(false)
	isHurt = false
	show()
	get_node("/root/Main/CanvasLayer/HealthUi").get_child(0).get_child(1).text = str(":   ", health)


func _on_get_hurt_by_trap_or_falling():
	position = levelStartPos
	isHurt = true
	loseHealthAndUpdateUI.emit()
	for torch in torchesArray:
		torch.get_node("CollisionShape2D").set_deferred("disabled", false)
		torch.get_node("Torch").visible = true

func _on_lose_health_and_update_ui():
	health -= 1
	get_node("/root/Main/CanvasLayer/HealthUi").get_child(0).get_child(1).text = str(":   ", health)
	if health > 0:
		$HurtStreamPlayer2D.play()


func _on_lose_level():
	levelLoseUI.set_visible(true)
	$WinStreamPlayer2D.stream = loseLevelSound
	$WinStreamPlayer2D.play()


func _on_attack():
	if !$SwordStreamPlayer2D.is_playing():
		$SwordStreamPlayer2D.play()
