#!/usr/bin/env bash
set -euo pipefail

echo "📦 Bootstrapping Flux into cluster..."

flux bootstrap github \
  --token-auth \
  --owner=$GH_USERNAME \
  --repository=$GH_REPOSITORY \
  --branch=$GH_BRANCH \
  --path=$GH_PATH \
  --personal

flux bootstrap "${bootstrap_args[@]}"

echo "🎉 Flux has been successfully bootstrapped from '$GH_OWNER/$GH_REPO' (branch: $GH_BRANCH, path: $GH_PATH)."
