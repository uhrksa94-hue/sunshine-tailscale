#!/bin/bash
set -e

# DBus starten
service dbus start

# SSH starten
service ssh start

# XRDP starten
service xrdp start

# Tailscale starten
tailscaled --state=/var/lib/tailscale/tailscaled.state &
sleep 3

if [ -n "$TS_AUTHKEY" ]; then
    echo "[INFO] Using AuthKey to connect Tailscale"
    tailscale up --authkey=$TS_AUTHKEY --hostname=vast-sunshine --accept-routes --accept-dns
else
    echo "[INFO] No AuthKey set. Run 'tailscale up' manually inside container."
fi

# Audio starten
pulseaudio --start

# NVIDIA GPU Info anzeigen (für Debugging)
echo "=== NVIDIA GPU Status ==="
nvidia-smi

# Warten bis alles gestartet ist
sleep 2

# Sunshine starten (als User vast)
sudo -u vast sunshine