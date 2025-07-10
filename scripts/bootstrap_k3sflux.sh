set -eux pipefail
TMP_SCRIPT=$(mktemp /tmp/bootstrap_flux.XXXXXX.py)
cleanup() {
  rm -f "$TMP_SCRIPT"
}
trap cleanup EXIT INT TERM
curl -s -o "$TMP_SCRIPT" https://raw.githubusercontent.com/MarcHoog/Devops/main/scripts/bootstrap_k3sflux.py
chmod +x "$TMP_SCRIPT"
python3 "$TMP_SCRIPT"
