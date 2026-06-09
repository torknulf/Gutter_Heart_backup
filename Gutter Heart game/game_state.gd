extends Node

var inCombat: bool = false

var hadCombatTutorial: bool = false

var queuedCombat

var npcStates = {
	"tutorial_guy": {
		"fought": false,
		"talk_count": 0
		
	}
}
