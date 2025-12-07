# Gameplay Loop

```mermaid
graph TD

CREATE(["Create Bug"]) --> INPUT

INPUT(["Awaiting player input"]) --> PLAY
INPUT --> IDLE
INPUT --> EVENT

subgraph Adventure_Loop
	ADVENTURE_LOOP(["Adventure Loop"])
	ITEMS(["Get items, e.g., food"])
	SKILL(["Upgrade stats"])
	ADVENTURE_LOOP --> ITEMS
	ITEMS --> ADVENTURE_LOOP
	ADVENTURE_LOOP --> SKILL

	SKILL -->|Stops when 'energy' depletes at 30 mins or so.| MAX(["Stats cannot be upgraded further"])

	MAX --> ADVENTURE_LOOP
end

IDLE(["Adventure Idly"]) -->|Less efficient| Adventure_Loop
PLAY(["Play Hollow Knight"]) ==> Adventure_Loop

EVENT(["Join event"]) -->|If stats meet threshhold| Win
EVENT -->|Otherwise| Lose

Win --> ADVANCE(["Advance Week"])
Lose --> ADVANCE

INPUT --> FEED(["Replenish Energy with Food"])
FEED --> INPUT


ADVANCE --> WEEK(["Passed required events?"])
WEEK --> SUCCESS(["Win the game"])
WEEK --> UNFINISHED(["Events not finished"]) ==> INPUT

WEEK --> FAILED(["Failed a required event"])
FAILED --> CREATE
```