#!/usr/bin/env bash
# fix-dns-port.sh — Frees port 53 from systemd-resolved for AdGuard Home
# Run once as root before deploying the network stack
set -euo pipefail

echo "[fix-dns-port] Disabling systemd-resolved stub listener..."

# Disable DNSStubListener
mkdir -p /etc/systemd/resolved.conf.d
cat > /etc/systemd/resolved.conf.d/no-stub.conf << 'CONF'
[Resolve]
DNSStubListener=no
DNS=1.1.1.1
CONF

# Restart resolved
systemctl restart systemd-resolved

echo "[fix-dns-port] Done. Port 53 is now free for AdGuard Home."
echo "[fix-dns-port] Verify with: ss -tlnup | grep :53"
