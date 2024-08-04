extends CanvasLayer

@onready var score_label = $ScoreLabel

var score = 0

var scoreText = "Coins: "

func add_point():
	score += 1
	score_label.text = scoreText + str(score)

func _ready():
	score_label.text = scoreText + "0"
