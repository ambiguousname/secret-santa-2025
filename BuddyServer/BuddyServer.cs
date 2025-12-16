#define TEST_WITHOUT_CLIENT

using System;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Text;
using Modding;
using System.Runtime.InteropServices.ComTypes;
using System.Threading.Tasks;
using UnityEngine;

namespace BuddyServer
{
    public class BuddyServer : Mod, ITogglableMod
    {
        private readonly TcpListener server = new TcpListener(IPAddress.Any, 5121);
        private GameStateReader reader = new GameStateReader();


        async private void CreateServer() {
            server.Start();
            while (true) {
#if !TEST_WITHOUT_CLIENT
                Log("Waiting for client...");
                TcpClient c = await server.AcceptTcpClientAsync();
                c.ReceiveTimeout = 1000;
                NetworkStream st = c.GetStream();
                Log("Client connected!");

                // We can't read or write.
                if (!(st.CanRead && st.CanWrite)) {
                    Log("Client stream does not support read or write. Disconnecting...");
                    c.Close();
                    continue;
                }

                string expected = "BuddyClient";
                byte[] buffer = new byte[expected.Length];
                await st.ReadAsync(buffer, 0, expected.Length);

                if (Encoding.UTF8.GetString(buffer) != expected) {
                    Log($"Handshake failed! Got {Encoding.UTF8.GetString(buffer)}");
                    c.Close();
                    continue;
                }

                await st.WriteAsync(Encoding.UTF8.GetBytes("BuddyServer"), 0, expected.Length);

                Log("Handshake succeeded.");
                while (c.Connected) {
#else
                while (true) {
#endif
                    reader.Update();
                    Log(reader.gameState.heroState);
                    // Not sure how long each frame will take (and we don't always want to send the same each frame), so we just send over the most important bits
                    // every second or so:
                    Thread.Sleep(1000);
                    // TODO: Send over state data.
                }
            }
        }

        Task tcpServerTask;
        CancellationTokenSource cts;

        public override void Initialize() {
            cts = new CancellationTokenSource();

            Log("Starting TCP server...");
            tcpServerTask = new Task(CreateServer, cts.Token, TaskCreationOptions.LongRunning);
            tcpServerTask.Start();
        }

        public override string GetVersion() => "0.0.1";

        public void Unload() {
            cts.Cancel();
            server.Stop();
            Log("Server stopped.");
        }
    }
}
