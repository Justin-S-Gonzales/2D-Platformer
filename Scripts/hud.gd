extends CanvasLayer

@onready var coin_label = $CoinLabel
@onready var lives_label = $LivesLabel

var scoreText = "Coins: "
var livesText = "Lives: "

func set_coins(coins):
	coin_label.text = scoreText + str(coins)
	
func set_lives(lives):
	lives_label.text = livesText + str(lives)	

func _ready():
	coin_label.text = scoreText + &"0"
	lives_label.text = livesText + &"0"
