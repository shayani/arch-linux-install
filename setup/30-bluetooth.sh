#!/usr/bin/env bash
# 30-bluetooth.sh - Bluetooth
set -euo pipefail
DIR=$(cd "$(dirname "$0")" && pwd); source "$DIR/lib.sh"

header "Bluetooth"
pacotes bluez bluez-utils bluetui
servicos bluetooth
