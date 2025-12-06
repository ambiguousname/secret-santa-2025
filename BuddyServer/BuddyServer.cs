using System;
using System.Net;
using System.Net.Sockets;
using System.Text;
using Modding;

namespace BuddyServer
{
    public class BuddyServer : Mod, ITogglableMod
    {
        private readonly TcpListener server = new TcpListener(IPAddress.Any, 5121);

        private bool shutdown = false;

        async private void ConnectClient() {

            while (true) {
                TcpClient c = await server.AcceptTcpClientAsync();
                c.ReceiveTimeout = 1000;
                NetworkStream st = c.GetStream();

                string expected = "BuddyClient";
                byte[] buffer = new byte[expected.Length];
                await st.ReadAsync(buffer, 0, expected.Length);

                if (Encoding.UTF8.GetString(buffer) != expected) {
                    c.Close();
                    continue;
                }

                await st.WriteAsync(Encoding.UTF8.GetBytes("BuddyServer"), 0, expected.Length);

                while (c.Connected && !shutdown) {
                    // TODO: Send over state data.
                }
                if (shutdown) {
                    return;
                }
            }
        }

        public override void Initialize() {
            server.Start();
            ConnectClient();
        }

        public override string GetVersion() => "0.0.1";

        public void Unload() {
            shutdown = true;
            server.Stop();
        }
    }
}
