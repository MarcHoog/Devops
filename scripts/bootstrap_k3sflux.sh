#!/usr/bin/env bash
set -euo pipefail

TMP_SCRIPT="/tmp/bootstrap_k3s_with_flux.py"

curl -s -O https://raw.githubusercontent.com/MarcHoog/Devops/main/scripts/bootstrap_k3sflux.py
chmod +x $TMP_SCRIPT
$TMP_SCRIPT
rm -f $TMP_SCRIPT