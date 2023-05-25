extends Node

# [ id ]
var players: Array = []
var player_nodes = {}
var names: Array = []
var playerTeams = {}

func setPlayerTeam(playerId, teamId):
	playerTeams[playerId] = teamId
