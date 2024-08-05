extends CanvasLayer

@onready var coin_label = $CoinLabel
@onready var lives_label = $LivesLabel
@onready var game_over_text = $"Game Over Text"

var scoreText = "Coins: "
var livesText = "Lives: "

func _ready():
	coin_label.text = scoreText + &"0"
	lives_label.text = livesText + &"0"
	game_over_text.set_visible(false)

func set_coins(coins):
	coin_label.text = scoreText + str(coins)
	
func set_lives(lives):
	lives_label.text = livesText + str(lives)	

func show_game_over():
	game_over_text.set_visible(true)
