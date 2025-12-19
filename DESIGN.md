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

# Playtesting Notes

## Playtester One

- [ ] (Probably done?) Appeared on second monitor (check which position it's appearing at?) (Setting position to zero does not guarantee it's at the start of the current screen)
- [X] Energy needs a label (called it "psychic damage")
- [X] Need some documentation (either in-game or out of game) on how it works
- Likes the super jump
- [X] Unclear of when to stop playing (day progression bar will help)
- [X] Make days until race longer and longer (start off at 1 day until race)
- [X] Day auto-advanced from 7 to 4 after running out of energy (???)

## Playtester Two

- [X] Unclear how to run and install Scarab (and note on detailed instructions to explainer in settings).
	- Also need to be clearer on HOW using this mod helps with the game
- [ ] Buddy should be smaller on screen
- [X] Need to test race kill conditions (and make them obvious)
- "It's kinda funny, I'm not against it." On having the pink square on bottom of screen
- [ ] Check TCP sending data on a quit to menu and reload
- "I did not realize I could input a name"
- [X] Need a bug rename state
- [ ] Buddy should be minimized after adventure is done and while TCP is active
- [X] Jumping at level 6 was not enough to clear
- Got two items, both Cool Skull. Had averages of skills around 6 or 7
- [ ] Need to test if this is better than without TCP (and if first race is passable almost regardless of stats)
- [ ] Racing backgrounds need a texture to be able to see on purely black.