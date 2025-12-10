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

Note that there should be a way to stop leveling at a certain point to stop grinding for an event. Then you regain whatever that is after completing an event. I'm thinking a timer that's stored as a save that counts down every 30 minutes (so it finishes at the end of an un-interrupted run), up to 7 times. So that at the end of the week, the event becomes mandatory.

## Skills and Stats
- Energy
	- Max cannot be increased
	- Can be replenished with food
- Running
- Climbing
- Skill 3
- Skill 4