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
	NO_ENERGY -->|No Items| NEXT_DAY(["Start next day with full energy."])

	ITEMS --> LOSE_ENERGY(["Lose Energy."])
	SKILL --> LOSE_ENERGY
	LOSE_ENERGY --> ENERGY
end

Adventure_Loop --> INPUT

IDLE(["Adventure Idly"]) -->|Less efficient| Adventure_Loop
PLAY(["Play Hollow Knight"]) ==>|Tied into in-game events e.g., taking damage improves your energy?| Adventure_Loop

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
	- Run unless any of the below happens.
- Climbing
	- Climb whenever there's a collision to the right, unless on a skateboard
- Jumping
	- Determines arc of your jump over a gap. Determine if there's a jump with a trigger.
	- Lose if you fall in
	- Add soft barrier right before any jumps to set x-accel to zero (to force the bug to land before hitting the hole)
		- OR have the bug calculate where it will land (since this will be a fixed position based on jump skill), and decrease jump arc until a valid hit.
- Skateboarding
	- Skateboards will show up in front of half-pipes
	- Determines how fast the bug will go down the half-pipe (while hopping on the skateboard)
	- Like jumping, dismounting on the half-pipe will create a jump arc (?)
	- Trigger to auto-equip skateboard (regardless of y-pos)

## Items
- Each should offer three choices:
	1. Upgrade Skill 1 for Y amount
	2. Upgrade Skill 2 for Y amount
	3. Replenish X energy
