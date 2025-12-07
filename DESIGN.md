# Gameplay Loop

```mermaid
graph

CREATE(["Create Bug"])@{ shape: diamond } --> INPUT

INPUT(["Awaiting player input"]) --> PLAY
INPUT --> IDLE
INPUT --> EVENT

subgraph Adventure_Loop [Adventure Loop]
	ENERGY(["Has energy?"])
	ENERGY --> ITEMS(["Get items, e.g., food"])
	ENERGY --> SKILL(["Upgrade stats"])
	ENERGY -->|Should deplete in 30 mins or so| NO_ENERGY(["Energy depleted."])

	ITEMS --> LOSE_ENERGY(["Lose Energy."])
	SKILL --> LOSE_ENERGY
	LOSE_ENERGY --> ENERGY
end

Adventure_Loop --> INPUT

IDLE(["Adventure Idly"]) -->|Less efficient| Adventure_Loop
PLAY(["Play Hollow Knight"]) ==>|Tied into in-game events (e.g., taking damage improves your energy?)| Adventure_Loop

EVENT(["Join event"]) -->|If stats meet threshhold| Win
EVENT -->|Otherwise| Lose

Win -->|Get rewards? Like a hat or a skin| ADVANCE(["Advance Week"])
Lose --> ADVANCE

INPUT --> FEED(["Replenish Energy with Food"])
FEED --> INPUT


ADVANCE --> WEEK(["Passed required events?"])
WEEK --> SUCCESS(["Win the game"])
WEEK --> UNFINISHED(["Events not finished"]) ==> INPUT

WEEK --> FAILED(["Failed a required event"])
FAILED --> CREATE
```