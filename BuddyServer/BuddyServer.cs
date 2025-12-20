//#define TEST_WITHOUT_CLIENT

using System.Net;
using System.Net.Sockets;
using System.Threading;
using System.Text;
using Modding;
using System.Threading.Tasks;

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
                c.SendTimeout = 1000;
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
#endif

#if TEST_WITHOUT_CLIENT
                while(true) {
#else
                while (c.Connected) {
#endif
                    reader.Update();
#if TEST_WITHOUT_CLIENT
                    Log(reader.GameStateString());
#else
                    string state = reader.GameStateString();
                    st.WriteAsync(Encoding.UTF8.GetBytes(state), 0, state.Length);
#endif
                    reader.ClearState();
                    // Not sure how to wait on reader's coroutine to process a frame, so we instead just wait each second and send only the important events.
                    Thread.Sleep(1000);
                }
                Log("Client disconnected.");
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
