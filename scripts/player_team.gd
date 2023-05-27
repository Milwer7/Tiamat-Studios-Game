extends HBoxContainer
@onready var namee = $namee
@onready var team = $team


func set_namee(value: String):
	namee.text = value

func set_team(value: int):
	if value:
		team.text = "Team " + str(value)


