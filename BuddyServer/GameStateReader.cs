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
                }
            }
        }

        public void ClearState() {
            gameState.heroState = "";
            gameState.events.Clear();
        }

        public string GameStateString() {
            return JsonConvert.SerializeObject(gameState);
        }

        float timer = 0.0f;

        float currStateStart = 0.0f;
        string prevState = "";
        IEnumerator GameFrameUpdate() {
            while (true) {
                timer = Time.time;
                var newState = activeController.hero_state.ToString();
                if (prevState != newState) {
                    gameState.events.Add(new Event(currStateStart, timer - currStateStart, "heroState", newState.ToString()));
                    currStateStart = timer;
                }
                gameState.heroState = newState;
                prevState = newState;
                yield return new WaitForEndOfFrame();
            }
        }
    }
}
