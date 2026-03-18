#!/usr/bin/env bash
# fix-dns-port.sh — Frees port 53 from systemd-resolved for AdGuard Home
# Usage: ./fix-dns-port.sh [--check|--apply|--restore]
set -euo pipefail

SYSTEMD_OVERRIDE_DIR=/etc/systemd/resolved.conf.d

check_status() {
  echo "=== systemd-resolved DNS stub listener status ==="
  ss -lnup 2>/dev/null | grep -q ":53 " && echo "  Port 53 IN USE" || echo "  Port 53 FREE"
  systemctl is-active --quiet systemd-resolved 2>/dev/null && echo "  systemd-resolved: ACTIVE" || echo "  systemd-resolved: INACTIVE"
}

apply_fix() {
  [[ $EUID -ne 0 ]] && { echo "ERROR: requires root"; exit 1; }
  mkdir -p "$SYSTEMD_OVERRIDE_DIR"
  printf "[Resolve]\nDNSStubListener=no\n" > "$SYSTEMD_OVERRIDE_DIR/no-stub.conf"
  systemctl restart systemd-resolved
  echo "Done. Port 53 free."
  check_status
}

restore() {
  [[ $EUID -ne 0 ]] && { echo "ERROR: requires root"; exit 1; }
  rm -f "$SYSTEMD_OVERRIDE_DIR/no-stub.conf"
  systemctl restart systemd-resolved
  echo "Restored."
  check_status
}

case "${1:-}" in
  --check)   check_status ;;
  --apply)   apply_fix ;;
  --restore) restore ;;
  *)         echo "Usage: $0 [--check|--apply|--restore]"; exit 1 ;;
esac
