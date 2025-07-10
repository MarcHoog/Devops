set -euxo pipefail
TMP_SCRIPT=$(mktemp /tmp/bootstrap_flux.XXXXXX.py)
cleanup() {
  rm -f "$TMP_SCRIPT"
}
trap cleanup EXIT INT TERM
curl -s -o "$TMP_SCRIPT" https://raw.githubusercontent.com/MarcHoog/Devops/main/scripts/bootstrap_k3s_with_flux.py
chmod +x "$TMP_SCRIPT"
"$TMP_SCRIPT"
