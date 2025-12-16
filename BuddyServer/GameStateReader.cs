using Modding;
using Modding.Converters;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Remoting.Messaging;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace BuddyServer {
    internal struct Event {
        public float start;
        public float duration;
        public string name;
        public object value;
        public Event(float s, float d, string n, object v) {
            duration = d;
            name = n;
            value = v;
            start = s;
        }

        public Event(Event copy) : this(copy.start, copy.duration, copy.name, copy.value) { }

        public Event(float s, string n, object v) {
            start = s;
            name = n;
            value = v;
            duration = 0.0f;
        }

        public Event(Event copy, float end) : this(copy.start, end - copy.start, copy.name, copy.value) {

        }
    };

    internal class GameState {
        public string heroState = "";
        public float hp = 0.0f;
        public List<Event> events = new List<Event>();
    }

    internal class GameStateReader {
        HeroController activeController;
        InputHandler inputHandler;
        public GameState gameState = new GameState();
        IEnumerator coroutine;

        public GameStateReader() {
            coroutine = GameFrameUpdate();
        }

        public void Update() {
            if (activeController == null) {
                if (GameManager.instance != null && GameManager.instance.hero_ctrl != null) {
                    activeController = GameManager.instance.hero_ctrl;
                    inputHandler = GameManager.instance.inputHandler;

                    timer = Time.time;
                    currStateStart = timer;

                    //Type t = activeController.GetType();

                    activeController.StartCoroutine(coroutine);
                    activeController.OnTakenDamage += () => {
                        gameState.events.Add(new Event(Time.time, "Damage", activeController.playerData.health));
                    };
                    activeController.OnDeath += () => {
                        gameState.events.Add(new Event(Time.time, "Death", activeController.playerData.health));
                    };
                }
            }
        }

        public void ClearState() {
            gameState.events.Clear();
        }

        public string GameStateString() {
            return JsonConvert.SerializeObject(gameState);
        }

        float timer = 0.0f;

        float currStateStart = 0.0f;

        float attackingStart = 0.0f;
        bool attacking = false;

        Event? bounceEvent;
        Event? wallSlideEvent;
        Event? wallTouchEvent;

        Event? jumpEvent;

        IEnumerator GameFrameUpdate() {
            while (true) {
                timer = Time.time;

                var newState = activeController.hero_state.ToString();
                if (gameState.heroState != newState) {
                    gameState.events.Add(new Event(currStateStart, timer - currStateStart, "heroState", newState.ToString()));
                    currStateStart = timer;
                }
                gameState.heroState = newState;

                if (activeController.cState.attacking && !attacking) {
                    attacking = true;
                    attackingStart = timer;
                } else if (attacking && !activeController.cState.attacking) {
                    attacking = false;
                    gameState.events.Add(new Event(attackingStart, timer - attackingStart, "attack", ""));
                }

                gameState.hp = activeController.playerData.health;

                if (activeController.cState.bouncing && bounceEvent == null) {
                    bounceEvent = new Event(timer, "bounce", "");
                } else if (!activeController.cState.bouncing && bounceEvent != null) {
                    gameState.events.Add(new Event(bounceEvent.Value, timer));
                    bounceEvent = null;
                }

                if (inputHandler.inputActions.jump.WasPressed && jumpEvent == null) {
                    jumpEvent = new Event(timer, "jump", "");
                } else if (inputHandler.inputActions.jump.WasReleased && jumpEvent != null) {
                    gameState.events.Add(new Event(jumpEvent.Value, timer));
                    jumpEvent = null;
                }

                if (activeController.cState.wallSliding && wallSlideEvent == null) {
                    wallSlideEvent = new Event(timer, "wallSlide", "");
                } else if (!activeController.cState.wallSliding && wallSlideEvent != null) {
                    gameState.events.Add(new Event(wallSlideEvent.Value, timer));
                    wallSlideEvent = null;
                }

                if (activeController.cState.touchingWall && wallTouchEvent == null) {
                    wallTouchEvent = new Event(timer, "wallTouch", "");
                } else if (!activeController.cState.touchingWall && wallTouchEvent != null) {
                    gameState.events.Add(new Event(wallTouchEvent.Value, timer));
                    wallTouchEvent = null;
                }

                yield return new WaitForEndOfFrame();
            }
        }
    }
}
