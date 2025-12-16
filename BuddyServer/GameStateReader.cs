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
    };

    internal class GameState {
        public string heroState = "";
        public float hp = 0.0f;
        public List<Event> events = new List<Event>();
    }

    internal class GameStateReader {
        HeroController activeController;
        public GameState gameState = new GameState();
        IEnumerator coroutine;

        public GameStateReader() {
            coroutine = GameFrameUpdate();
        }

        public void Update() {
            if (activeController == null) {
                HeroController[] controllers = UnityEngine.Object.FindObjectsOfType<HeroController>();
                if (controllers.Length > 0) {
                    activeController = controllers[0];

                    timer = Time.time;
                    currStateStart = timer;

                    activeController.StartCoroutine(coroutine);
                    activeController.OnTakenDamage += () => {
                        gameState.events.Add(new Event(Time.time, 0.0f, "Damage", activeController.playerData.health));
                    };
                    activeController.OnDeath += () => {
                        gameState.events.Add(new Event(Time.time, 0.0f, "Death", activeController.playerData.health));
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
                
                yield return new WaitForEndOfFrame();
            }
        }
    }
}
