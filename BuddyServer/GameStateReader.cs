using Modding;
using Modding.Converters;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEngine;

namespace BuddyServer {
    internal class GameState {
        public string heroState = "";
    }
    internal class GameStateReader {
        HeroController activeController;
        public GameState gameState = new GameState();

        public void Update() {
            if (activeController == null) {
                HeroController[] controllers = UnityEngine.Object.FindObjectsOfType<HeroController>();
                if (controllers.Length > 0) {
                    activeController = controllers[0];
                }
            } else {
                if (activeController.acceptingInput) {
                    gameState.heroState = activeController.hero_state.ToString();
                }
            }
        }
    }
}
